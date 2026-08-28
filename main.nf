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
include { BUILD_DRIVER_PANGENOME  } from './subworkflows/local/build_driver_pangenome'
include { CALL_RECURRENT_VARIANTS } from './subworkflows/local/call_recurrent_variants'
include { CALL_PERSONAL_VARIANTS  } from './subworkflows/local/call_personal_variants'
include { VG_AUTOINDEX            } from './modules/local/vg/autoindex'

// ----------------------------------------------------------------------------------------
// Parameter Definitions
// ----------------------------------------------------------------------------------------
params {
    help                   : Boolean = false
    input                  : Path?   = null  // Driver SV VCF file or samplesheet
    variants               : Path?   = null  // Driver variant manifest TSV
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
              1. Build pangenome from VCF (Default):
                 nextflow run main.nf --input driver_svs.vcf -profile test,singularity

              2. Use pre-built GFA pangenome graph:
                 nextflow run main.nf --pangenome cancer_driver.gfa -profile test,singularity

              3. Use pre-built pangenome index files (Bypasses Subworkflow 1):
                 nextflow run main.nf --pangenome_index "path/to/gbz,path/to/dist,path/to/min" -profile test,singularity

            Options:
              --input            Path to input driver SV VCF file
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
    def vcf_input = params.input ?: params.variants ?: "${projectDir}/assets/test/driver_svs.vcf"

    log.info """
        ===================================================================
        SVantigen Pipeline
        ===================================================================
        input           : ${vcf_input}
        pangenome       : ${params.pangenome}
        pangenome_index : ${params.pangenome_index}
        fasta           : ${ref_fasta}
        reads           : ${params.reads}
        outdir          : ${params.outdir}
        enable_gpu      : ${params.enable_gpu}
        ===================================================================
    """.stripIndent()

    // ------------------------------------------------------------------------
    // Shared Input Channels
    // ------------------------------------------------------------------------
    ch_fasta = Channel.fromPath(ref_fasta, checkIfExists: true)
                .map { file -> [ [id: file.baseName], file ] }
    ch_reads = Channel.fromPath(params.reads ?: "${projectDir}/assets/test/tumor_short.fastq.gz", checkIfExists: true)
                .map { file -> [ [id: file.baseName], file ] }

    // ------------------------------------------------------------------------
    // 1. Pangenome Graph & Index Resolution
    // ------------------------------------------------------------------------
    ch_pangenome_index = Channel.empty()

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
    } else if (vcf_input) {
        log.info "--> Mode: Building pangenome graph and index from scratch using VCF (${vcf_input})."
        ch_vcf = Channel.fromPath(vcf_input, checkIfExists: true)
                    .map { file -> [ [id: file.baseName], file ] }
        
        BUILD_DRIVER_PANGENOME( ch_vcf, ch_fasta )
        ch_pangenome_index = BUILD_DRIVER_PANGENOME.out.index
    } else {
        failParam("Please specify one of: --input (VCF), --pangenome (GFA), or --pangenome_index (.gbz,.dist,.min).")
    }

    // ------------------------------------------------------------------------
    // 2. Call Recurrent Drivers / Neoantigens (Pangenome Giraffe Alignment & Calling)
    // ------------------------------------------------------------------------
    CALL_RECURRENT_VARIANTS( ch_reads, ch_pangenome_index )

    // ------------------------------------------------------------------------
    // 3. De Novo Call Somatic SVs / Small Variants (Minimap2 + DeepSomatic + Sniffles2)
    // ------------------------------------------------------------------------
    CALL_PERSONAL_VARIANTS( ch_reads, ch_fasta )
}
