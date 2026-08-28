/*
 * SUBWORKFLOW: CALL_PERSONAL_VARIANTS
 * Purpose  : Align long/short reads to linear reference genome and call personal small & structural variants
 * Status   : complete implementation
 *
 * Processes: SAMTOOLS_BAM2FASTQ, SAMTOOLS_FAIDX, MINIMAP2_ALIGN / PARABRICKS_MINIMAP2_ALIGN, DEEPSOMATIC_CALL / PARABRICKS_DEEPSOMATIC_CALL, SNIFFLES2_CALL
 *
 * Inputs:
 *  - ch_reads : [ val(meta), [ path(reads) ] ] - FASTQ or BAM tumor reads
 *  - ch_fasta : [ val(meta_fasta), path(fasta) ] - Linear reference FASTA
 *
 * Outputs:
 *  - aligned   : [ val(meta), path(bam) ] - Coordinate-sorted aligned BAM
 *  - small_vcf : [ val(meta), path(vcf) ] - Small somatic variants (DeepSomatic)
 *  - sv_vcf    : [ val(meta), path(vcf) ] - Structural variants (Sniffles2)
 *  - versions  : [ path(versions.yml) ] - Software versions
 *
 * Notes:
 *  - Generates FASTA .fai index with samtools faidx
 *  - Performs CPU or GPU Minimap2 read alignment
 *  - Calls small somatic variants with DeepSomatic and SVs with Sniffles2
 */

include { SAMTOOLS_BAM2FASTQ          } from '../../modules/local/samtools/bam2fastq.nf'
include { SAMTOOLS_FAIDX              } from '../../modules/local/samtools/faidx.nf'
include { MINIMAP2_ALIGN              } from '../../modules/local/minimap2/align.nf' 
include { DEEPSOMATIC_CALL            } from '../../modules/local/deepsomatic/call.nf'
include { SNIFFLES2_CALL              } from '../../modules/local/sniffles2/call.nf'

// FOR GPU ACCELERATION
include { PARABRICKS_MINIMAP2_ALIGN   } from '../../modules/local/parabricks/minimap2/align.nf' 
include { PARABRICKS_DEEPSOMATIC_CALL } from '../../modules/local/parabricks/deepsomatic/call.nf'

workflow CALL_PERSONAL_VARIANTS {

    take:
    ch_reads  // channel: [ val(meta), [ path(reads) ] ] (BAM or FASTQ)
    ch_fasta  // channel: [ val(meta_fasta), path(fasta) ]

    main:
    ch_versions = Channel.empty()

    // 1. Separate BAM vs FASTQ input
    ch_reads
        .branch { meta, reads ->
            def read_list = reads instanceof List ? reads : [reads]
            bam: read_list[0].name.endsWith('.bam')
            fastq: true
        }
        .set { ch_input_reads }

    // Convert BAM to FASTQ if required
    SAMTOOLS_BAM2FASTQ ( ch_input_reads.bam )
    ch_versions = ch_versions.mix(SAMTOOLS_BAM2FASTQ.out.versions)

    ch_fastqs = ch_input_reads.fastq.mix(SAMTOOLS_BAM2FASTQ.out.fastq)

    // Index reference FASTA
    SAMTOOLS_FAIDX ( ch_fasta )
    ch_fa_fai   = SAMTOOLS_FAIDX.out.fa_fai
    ch_versions = ch_versions.mix(SAMTOOLS_FAIDX.out.versions)

    // 2. Align reads to reference genome (CPU or GPU Minimap2)
    if (params.enable_gpu) {
        PARABRICKS_MINIMAP2_ALIGN ( ch_fastqs, ch_fasta )
        ch_aligned_reads = PARABRICKS_MINIMAP2_ALIGN.out.bam
        ch_aligned_bai   = PARABRICKS_MINIMAP2_ALIGN.out.bai
        ch_versions      = ch_versions.mix(PARABRICKS_MINIMAP2_ALIGN.out.versions)
    } else {
        MINIMAP2_ALIGN ( ch_fastqs, ch_fasta )
        ch_aligned_reads = MINIMAP2_ALIGN.out.bam
        ch_aligned_bai   = MINIMAP2_ALIGN.out.bai
        ch_versions      = ch_versions.mix(MINIMAP2_ALIGN.out.versions)
    }

    ch_aligned_with_bai = ch_aligned_reads.join(ch_aligned_bai)

    // 3. Call small somatic variants (DeepSomatic CPU or GPU)
    if (params.enable_gpu) {
        PARABRICKS_DEEPSOMATIC_CALL ( ch_aligned_reads, ch_fasta )
        ch_small_vcf = PARABRICKS_DEEPSOMATIC_CALL.out.vcf
        ch_versions  = ch_versions.mix(PARABRICKS_DEEPSOMATIC_CALL.out.versions)
    } else {
        DEEPSOMATIC_CALL ( ch_aligned_with_bai, ch_fa_fai )
        ch_small_vcf = DEEPSOMATIC_CALL.out.vcf
        ch_versions  = ch_versions.mix(DEEPSOMATIC_CALL.out.versions)
    }

    // 4. Call structural variants (Sniffles2)
    // Use .collect() so ch_tandem acts as a reusable value channel across all samples
    ch_tandem = Channel.of( [ [id: 'no_tandem'], file('NO_FILE') ] ).collect()

    SNIFFLES2_CALL ( ch_aligned_with_bai, ch_fasta, ch_tandem )
    ch_sv_vcf   = SNIFFLES2_CALL.out.vcf
    ch_versions = ch_versions.mix(SNIFFLES2_CALL.out.versions)

    emit:
    aligned     = ch_aligned_reads // channel: [ val(meta), path(bam) ]
    small_vcf   = ch_small_vcf     // channel: [ val(meta), path(vcf) ]
    sv_vcf      = ch_sv_vcf        // channel: [ val(meta), path(vcf) ]
    versions    = ch_versions      // channel: [ path(versions.yml) ]
}
