#!/usr/bin/env nextflow

/*
========================================================================================
    SVANTIGEN PIPELINE SCAFFOLD
========================================================================================
    Minimal Nextflow DSL2 scaffold.
    Add real logic under modules/local/ and subworkflows/local/ as we build things out.
========================================================================================
*/

nextflow.enable.dsl = 2

// ----------------------------------------------------------------------------
// Subworkflow includes
// ----------------------------------------------------------------------------
include { INPUT_CHECK          } from './subworkflows/local/input_check'
include { BUILD_DRIVER_PANGENOME } from './subworkflows/local/build_driver_pangenome'
// include { CALL_RECURRENT_VARIANTS } from './subworkflows/local/call_recurrent_variants'
// include { CALL_PERSONAL_VARIANTS  } from './subworkflows/local/call_personal_variants'

workflow {

    log.info """
        SVantigen Pipeline Scaffold
        ===========================
        input  : ${params.input}
        outdir : ${params.outdir}
    """.stripIndent()

    // ------------------------------------------------------------------------
    // Parse the samplesheet into typed tumor/normal channels (issue #19)
    // ------------------------------------------------------------------------
    ch_input = channel.fromPath(params.input)
    INPUT_CHECK(ch_input)

    // Future issues will wire these channels to analysis subworkflows:
    // ch_short_tumor  = INPUT_CHECK.out.short_tumor
    // ch_short_normal = INPUT_CHECK.out.short_normal
    // ch_long_tumor   = INPUT_CHECK.out.long_tumor
    // ch_long_normal  = INPUT_CHECK.out.long_normal

    // ------------------------------------------------------------------------
    // Variation graph construction (BUILD_DRIVER_PANGENOME).
    // Reads reference + variant inputs from params and publishes the GFA graph,
    // the vg GBZ graph, and the giraffe index set to params.outdir/pangenome.
    // ------------------------------------------------------------------------
    BUILD_DRIVER_PANGENOME()

}
