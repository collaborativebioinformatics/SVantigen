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
include { INPUT_CHECK             } from './subworkflows/local/input_check'
include { BUILD_DRIVER_PANGENOME  } from './subworkflows/local/build_driver_pangenome'
include { CALL_RECURRENT_VARIANTS } from './subworkflows/local/call_recurrent_variants'
include { CALL_PERSONAL_VARIANTS  } from './subworkflows/local/call_personal_variants'

workflow {

    log.info """
        SVantigen Pipeline
        ==================
        input      : ${params.input}
        reference  : ${params.reference}
        variants   : ${params.variants}
        outdir     : ${params.outdir}
        enable_gpu : ${params.enable_gpu}
        run_personal_variants : ${params.run_personal_variants}
    """.stripIndent()

    if (!params.input) {
        error "Missing required param --input (tumor/normal samplesheet CSV)."
    }
    if (!params.reference) {
        error "Missing required param --reference (reference FASTA)."
    }
    if (!params.variants) {
        error "Missing required param --variants (driver-variant manifest TSV)."
    }

    // ------------------------------------------------------------------------
    // Parse the samplesheet into typed tumor/normal channels (issue #19)
    // ------------------------------------------------------------------------
    ch_samplesheet = Channel.fromPath(params.input)
    INPUT_CHECK(ch_samplesheet)

    // ------------------------------------------------------------------------
    // Canonical input channels
    // ------------------------------------------------------------------------
    ch_reference = channel
        .fromPath(params.reference, checkIfExists: true)
        .map { ref -> [ [id: 'reference'], ref ] }

    ch_reference_index = channel
        .fromPath(params.reference_index ?: "${params.reference}.fai", checkIfExists: true)
        .map { fai -> [ [id: 'reference'], fai ] }

    ch_variants = channel
        .fromPath(params.variants, checkIfExists: true)
        .map { manifest -> [ [id: 'driver_variants'], manifest ] }

    ch_short_reads = INPUT_CHECK.out.short_tumor.mix(INPUT_CHECK.out.short_normal)

    // 1. Build cancer driver pangenome indexes
    BUILD_DRIVER_PANGENOME(ch_reference, ch_reference_index, ch_variants)

    // 2. Run recurrent-variant branch using typed short-read channels
    CALL_RECURRENT_VARIANTS(ch_short_reads, BUILD_DRIVER_PANGENOME.out.index)

    // 3. Personal-variant branch remains disabled until issues #6 and #20 are complete
    if (params.run_personal_variants) {
        log.warn "run_personal_variants=true is not supported yet; CALL_PERSONAL_VARIANTS remains disabled pending issues #6 and #20."
    }

}
