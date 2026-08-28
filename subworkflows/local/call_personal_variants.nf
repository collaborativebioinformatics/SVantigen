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

    // Step 3: pair each BAM with its index, then split the mixed stream back
    // into tumor and normal lanes using the status carried in meta.
    ch_aligned = MINIMAP2_ALIGN.out.bam
        .join(MINIMAP2_ALIGN.out.bai)
        .branch { meta, bam, bai ->
            tumor:  meta.status == 'tumor'
            normal: meta.status == 'normal'
        }

    // Step 4a: SNV/indel calling. Re-pair tumor with its matched normal
    // on pair_id so DeepSomatic can subtract germline from tumor.
    ch_somatic_input = ch_aligned.tumor
        .map { meta, bam, bai -> [ meta.pair_id, meta, bam, bai ] }
        .join( ch_aligned.normal.map { meta, bam, bai -> [ meta.pair_id, bam, bai ] } )
        .map { pair_id, meta, t_bam, t_bai, n_bam, n_bai ->
            [ meta, t_bam, t_bai, n_bam, n_bai ]
        }

    DEEPSOMATIC_CALL(ch_somatic_input, ch_reference)

    // Step 4b: structural variant calling on the tumor alignment.
    // No tandem-repeat annotation yet, so pass the NO_FILE placeholder.
    ch_no_tandem = Channel.value([ [id: 'no_tandem'], file('NO_FILE') ])

    SNIFFLES2_CALL(ch_aligned.tumor, ch_reference, ch_no_tandem)

    emit:
    snv_vcf = DEEPSOMATIC_CALL.out.vcf   // personal SNV/indel calls
    sv_vcf  = SNIFFLES2_CALL.out.vcf     // personal structural variant calls
    bam     = MINIMAP2_ALIGN.out.bam     // alignments, reused by downstream QC
}