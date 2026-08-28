/*
 * SUBWORKFLOW: CALL_PERSONAL_VARIANTS
 * Purpose  : Align reads to the traditional reference and call variants.
 *            Discover personal (patient-private) variants from matched
 *            tumor/normal long reads aligned to the linear reference.
 *
 * Processes: SAMTOOLS_BAM2FASTQ, MINIMAP2_ALIGN, DEEPSOMATIC_CALL, SNIFFLES2_CALL
 *
 * Inputs:
 *   - ch_tumor_bam  : [ meta, bam ] tumor long-read BAM
 *   - ch_normal_bam : [ meta, bam ] normal long-read BAM
 *   - ch_reference  : [ meta, fasta ] linear reference genome
 *
 * Outputs:
 *   - snv_vcf : personal SNV/indel calls (from DeepSomatic)
 *   - sv_vcf  : personal structural variant calls (from Sniffles2)
 * Status   : scaffold, module commands not yet implemented
 * Notes    : The [ meta, bam ] notation is the repo's shorthand for 
 *            a Nextflow channel carrying a tuple: a small map of sample metadata 
 *            travelling alongside the file
 *
 */

include { SAMTOOLS_BAM2FASTQ } from '../../modules/local/samtools/bam2fastq.nf'
include { MINIMAP2_ALIGN     } from '../../modules/local/minimap2/align.nf' 
include { DEEPSOMATIC_CALL   } from '../../modules/local/deepsomatic/call.nf'
include { SNIFFLES2_CALL     } from '../../modules/local/sniffles2/call.nf'

// FOR GPU ACCELERATION
include { PARABRICKS_MINIMAP2_ALIGN     } from '../../modules/local/parabricks/minimap2/align.nf' 
include { PARABRICKS_DEEPSOMATIC_CALL   } from '../../modules/local/parabricks/deepsomatic/call.nf'


workflow CALL_PERSONAL_VARIANTS {

    take:
    ch_tumor_bam  // [ meta, bam ] tumor long-read BAM
    ch_normal_bam // [ meta, bam ] normal long-read BAM
    ch_reference  //[ meta, fasta ] linear reference genome

    main:
    // Step 1: strip both BAMs back to raw reads.
    // Mixing tumor + normal into one channel means one process call and
    // one task per sample, instead of two hard-coded calls.
    ch_bams   = ch_tumor_bam.mix(ch_normal_bam)
    ch_fastq  = SAMTOOLS_BAM2FASTQ(ch_bams)

    // Step 2: align each sample's reads to the linear reference.
    // combine pairs every FASTQ with the single reference item, then map
    // reshapes it into the [ meta, reference, reads ] tuple the module wants.
    ch_align_input = ch_fastq
        .combine(ch_reference)
        .map { meta, fastq, meta_ref, fasta -> [ meta, fasta, fastq ] }

    MINIMAP2_ALIGN(ch_align_input)

    // emit:
    // // ch_output
}