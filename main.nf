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
include { BUILD_DRIVER_PANGENOME  } from './subworkflows/local/build_driver_pangenome'
// include { CALL_RECURRENT_VARIANTS } from './subworkflows/local/call_recurrent_variants'
// include { CALL_PERSONAL_VARIANTS  } from './subworkflows/local/call_personal_variants'

workflow {

    log.info """
        SVantigen Pipeline Scaffold
        ==========================
        input  : ${params.input}
        outdir : ${params.outdir}
    """.stripIndent()

    // ------------------------------------------------------------------------
    // Variation graph construction (BUILD_DRIVER_PANGENOME).
    // Reads reference + variant inputs from params and publishes the GFA graph,
    // the vg GBZ graph, and the giraffe index set to params.outdir/pangenome.
    // ------------------------------------------------------------------------
    BUILD_DRIVER_PANGENOME()

}
