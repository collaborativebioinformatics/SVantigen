/*
 * SUBWORKFLOW: CALL_RECURRENT_VARIANTS
 * Purpose  : Align reads to the created cancer driver pangenome and call variants
 * Status   : placeholder, not yet implemented
 * Assigned : to be assigned
 */

include { SAMTOOLS_BAM2FASTQ      } from '../../modules/local/samtools/bam2fastq.nf'   
include { VG_GIRAFFE              } from '../../modules/local/vg/giraffe.nf' 
include { VG_PACK                 } from '../../modules/local/vg/pack.nf'
include { VG_CALL                 } from '../../modules/local/vg/call.nf'
include { FILTER_SOMATIC_VARIANTS } from '../../modules/local/filter_somatic_variants.nf'   
include { COLLECT_QC_REPORT       } from '../../modules/local/collect_qc_report.nf'

// FOR GPU ACCELERATION
include { PARABRICKS_VG_GIRAFFE   } from '../../modules/local/parabricks/vg/giraffe.nf' 

workflow CALL_RECURRENT_VARIANTS {

    // take:
    // // ch_input

    // main:
    // // TODO: implement logic

    // emit:
    // // ch_output
}
