#!/usr/bin/env nextflow

/*
========================================================================================
    SVANTIGEN PIPELINE SCAFFOLD
========================================================================================
    Minimal Nextflow DSL2 scaffold.
========================================================================================
*/

// ----------------------------------------------------------------------------
// Subworkflow includes
// ----------------------------------------------------------------------------
include { BUILD_DRIVER_PANGENOME  } from './subworkflows/local/build_driver_pangenome'
include { CALL_RECURRENT_VARIANTS } from './subworkflows/local/call_recurrent_variants'

workflow {

    log.info """
        SVantigen Pipeline
        ==================
        input      : ${params.input}
        outdir     : ${params.outdir}
        enable_gpu : ${params.enable_gpu}
    """.stripIndent()

    // ------------------------------------------------------------------------
    // Channel initialization
    // ------------------------------------------------------------------------
    if (params.input) {
        ch_vcf   = Channel.fromPath(params.input).map { file -> [ [id: file.baseName], file ] }
        ch_fasta = Channel.fromPath(params.fasta ?: 'assets/test/reference.fasta').map { file -> [ [id: file.baseName], file ] }
        ch_reads = Channel.fromPath(params.reads ?: 'assets/test/tumor_short.fastq.gz').map { file -> [ [id: file.baseName], file ] }

        // 1. Build Cancer Driver Pangenome Index (GFA -> Giraffe GBZ, DIST, MIN)
        BUILD_DRIVER_PANGENOME( ch_vcf, ch_fasta )

        // 2. Align reads to pangenome & call recurrent variants (GPU / CPU Giraffe)
        CALL_RECURRENT_VARIANTS( ch_reads, BUILD_DRIVER_PANGENOME.out.index )
    }
}
