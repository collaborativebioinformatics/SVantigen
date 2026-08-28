#!/usr/bin/env nextflow

/*
========================================================================================
    SVANTIGEN PIPELINE
========================================================================================
    Identifying candidate neoantigens and druggable mutations in SV space
========================================================================================
*/

// ----------------------------------------------------------------------------------------
// Subworkflow & Module Includes
// ----------------------------------------------------------------------------------------
include { INPUT_CHECK             } from './subworkflows/local/input_check'
include { BUILD_DRIVER_PANGENOME  } from './subworkflows/local/build_driver_pangenome'
include { CALL_RECURRENT_VARIANTS } from './subworkflows/local/call_recurrent_variants'
include { CALL_PERSONAL_VARIANTS  } from './subworkflows/local/call_personal_variants'
include { VG_AUTOINDEX            } from './modules/local/vg/autoindex'

// ----------------------------------------------------------------------------------------
// Parameter Definitions
// ----------------------------------------------------------------------------------------
params {
    help                   : Boolean = false
    input                  : Path?   = null  // Samplesheet CSV or Driver SV VCF file
    variants               : Path?   = null  // Driver variant manifest VCF / TSV
    pangenome              : Path?   = null  // Pre-built GFA pangenome file
    pangenome_index        : String? = null  // Pre-built pangenome index files (.gbz, .dist, .min)
    fasta                  : Path?   = null  // Reference genome FASTA file
    reference              : Path?   = null  // Alias for reference genome FASTA file
    reads                  : Path?   = null  // Input short/long FASTQ/BAM reads
    outdir                 : String  = './results'
    publish_dir_mode       : String  = 'copy'
    enable_gpu             : Boolean = false
    apptainer_cache_dir    : String
    apptainer_library_dir  : String
    software_versions_path : String
}

def failParam(String msg) {
    log.error msg
    System.exit(1)
}

workflow {

    if (params.help) {
        log.info """
            ===================================================================
            SVantigen Pipeline - Identifying Candidate Neoantigens in SV Space
            ===================================================================
            Usage:
              1. Build pangenome from VCF & run with samplesheet (Default):
                 nextflow run main.nf --input samplesheet.csv --variants driver_svs.vcf -profile test,singularity

              2. Use pre-built GFA pangenome graph:
                 nextflow run main.nf --input samplesheet.csv --pangenome cancer_driver.gfa -profile test,singularity

              3. Use pre-built pangenome index files (Bypasses Subworkflow 1):
                 nextflow run main.nf --input samplesheet.csv --pangenome_index "path/to/gbz,path/to/dist,path/to/min" -profile test,singularity

            Options:
              --input            Path to samplesheet CSV or input VCF
              --variants         Path to driver variant VCF / TSV manifest
              --pangenome        Path to pre-built GFA pangenome file
              --pangenome_index  Path or comma-separated list to pre-built index files (.gbz, .dist, .min)
              --fasta            Path to reference genome FASTA file
              --reads            Path to input tumor FASTQ/BAM file
              --outdir           Output directory for results [default: ./results]
              --enable_gpu       Enable GPU-accelerated execution [default: false]
            """.stripIndent()
        exit 0
    }

    def ref_fasta = params.fasta ?: params.reference ?: "${projectDir}/assets/test/reference.fasta"
    def input_path = params.input ? params.input.toString() : null
    def is_samplesheet = input_path && input_path.endsWith('.csv')

    log.info """
        ===================================================================
        SVantigen Pipeline
        ===================================================================
        input           : ${params.input}
        variants        : ${params.variants}
        pangenome       : ${params.pangenome}
        pangenome_index : ${params.pangenome_index}
        fasta           : ${ref_fasta}
        reads           : ${params.reads}
        outdir          : ${params.outdir}
        enable_gpu      : ${params.enable_gpu}
        ===================================================================
    """.stripIndent()

    // ------------------------------------------------------------------------
    // Shared Input Channels & Read Type Routing
    // ------------------------------------------------------------------------
    ch_fasta = Channel.fromPath(ref_fasta, checkIfExists: true)
                .map { file -> [ [id: file.baseName], file ] }

    ch_short_reads = Channel.empty()
    ch_long_reads  = Channel.empty()

    if (is_samplesheet) {
        log.info "--> Mode: Parsing samplesheet CSV (${params.input}) via INPUT_CHECK."
        ch_samplesheet = Channel.fromPath(params.input, checkIfExists: true)
        INPUT_CHECK( ch_samplesheet )

        // Route short reads -> CALL_RECURRENT_VARIANTS
        ch_short_reads = INPUT_CHECK.out.short_tumor.mix(INPUT_CHECK.out.short_normal)

        // Route long reads -> CALL_PERSONAL_VARIANTS
        ch_long_reads  = INPUT_CHECK.out.long_tumor.mix(INPUT_CHECK.out.long_normal)
    } else if (params.reads) {
        def reads_str = params.reads.toString()
        if (reads_str.contains('long')) {
            ch_long_reads  = Channel.fromPath(params.reads, checkIfExists: true)
                                .map { file -> [ [id: file.baseName], file ] }
        } else {
            ch_short_reads = Channel.fromPath(params.reads, checkIfExists: true)
                                .map { file -> [ [id: file.baseName], file ] }
        }
    } else {
        ch_short_reads = Channel.fromPath("${projectDir}/assets/test/sample01.short.bam", checkIfExists: true)
                            .map { file -> [ [id: file.baseName], file ] }
        ch_long_reads  = Channel.fromPath("${projectDir}/assets/test/sample03.long.bam", checkIfExists: true)
                            .map { file -> [ [id: file.baseName], file ] }
    }

    // ------------------------------------------------------------------------
    // 1. Pangenome Graph & Index Resolution
    // ------------------------------------------------------------------------
    ch_pangenome_index = Channel.empty()
    def vcf_driver = params.variants ?: (!is_samplesheet ? params.input : null) ?: "${projectDir}/assets/test/driver_svs.vcf"

    if (params.pangenome_index) {
        log.info "--> Mode: Using pre-built pangenome index (${params.pangenome_index}). Bypassing Subworkflow 1."
        def index_paths = params.pangenome_index.toString().split(',').collect { file(it.trim()) }
        ch_pangenome_index = Channel.fromPath(index_paths, checkIfExists: true)
            .collect()
            .map { files ->
                def gbz  = files.find { it.name.endsWith('.gbz') }
                def dist = files.find { it.name.endsWith('.dist') }
                def min  = files.find { it.name.endsWith('.min') }
                if (!gbz || !dist || !min) {
                    log.error "Could not locate all 3 index files (.gbz, .dist, .min) in --pangenome_index: ${params.pangenome_index}"
                    System.exit(1)
                }
                [ [id: gbz.baseName.replaceAll('\\.giraffe$', '')], gbz, dist, min ]
            }
    } else if (params.pangenome) {
        log.info "--> Mode: Using pre-built GFA graph (${params.pangenome}). Indexing via VG_AUTOINDEX."
        ch_gfa = Channel.fromPath(params.pangenome, checkIfExists: true)
                    .map { file -> [ [id: file.baseName], file ] }
        VG_AUTOINDEX( ch_gfa )
        ch_pangenome_index = VG_AUTOINDEX.out.index
    } else if (vcf_driver) {
        log.info "--> Mode: Building pangenome graph and index from scratch using VCF (${vcf_driver})."
        ch_vcf = Channel.fromPath(vcf_driver, checkIfExists: true)
                    .map { file -> [ [id: file.baseName], file ] }
        
        BUILD_DRIVER_PANGENOME( ch_vcf, ch_fasta )
        ch_pangenome_index = BUILD_DRIVER_PANGENOME.out.index
    } else {
        failParam("Please specify one of: --input (VCF/samplesheet), --pangenome (GFA), or --pangenome_index (.gbz,.dist,.min).")
    }

    // ------------------------------------------------------------------------
    // 2. Call Recurrent Drivers / Neoantigens (Short Reads -> Pangenome Giraffe Alignment & Calling)
    // ------------------------------------------------------------------------
    CALL_RECURRENT_VARIANTS( ch_short_reads, ch_pangenome_index )

    // ------------------------------------------------------------------------
    // 3. De Novo Call Somatic SVs / Small Variants (Long Reads -> Minimap2 + DeepSomatic + Sniffles2)
    // ------------------------------------------------------------------------
    CALL_PERSONAL_VARIANTS( ch_long_reads, ch_fasta )
}
