/*
 * SUBWORKFLOW: CALL_PERSONAL_VARIANTS
 * Purpose  : Align reads to the traditional reference and call variants
 * Status   : placeholder, not yet implemented
 * Assigned : to be assigned
 */

include { SAMTOOLS_BAM2FASTQ } from '../../modules/local/samtools/bam2fastq.nf'   
include { MINIMAP2_ALIGN     } from '../../modules/local/minimap2/align.nf' 
include { DEEPSOMATIC_CALL   } from '../../modules/local/deepsomatic/call.nf'
include { SNIFFLES2_CALL     } from '../../modules/local/sniffles2/call.nf'


workflow CALL_PERSONAL_VARIANTS {

    // take:
    // // ch_input

    // main:
    // // TODO: implement logic

    // emit:
    // // ch_output
}
