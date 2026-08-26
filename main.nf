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
// include { BUILD_DRIVER_PANGENOME  } from './subworkflows/local/build_driver_pangenome'
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
    // Wire up subworkflows here as they're implemented, e.g.:
    //
    // input_ch = Channel.fromPath(params.input)
    // BUILD_DRIVER_PANGENOME( input_ch )
    // ------------------------------------------------------------------------

}
