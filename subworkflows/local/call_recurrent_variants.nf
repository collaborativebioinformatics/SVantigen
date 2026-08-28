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

// FOR GPU ACCELERATION (NVIDIA Parabricks Giraffe - Issue #9)
include { PARABRICKS_VG_GIRAFFE   } from '../../modules/local/parabricks/vg/giraffe.nf' 

workflow CALL_RECURRENT_VARIANTS {

    take:
    ch_reads          // channel: [ val(meta), [ path(reads) ] ] (BAM or FASTQ)
    ch_giraffe_index  // channel: [ val(meta_idx), path(gbz), path(dist), path(min) ]

    main:
    ch_versions = channel.empty()

    // 1. Separate BAM vs FASTQ input
    ch_reads
        .branch { meta, reads ->
            def read_list = reads instanceof List ? reads : [reads]
            def is_bam = read_list[0].name.endsWith('.bam')

            bam: is_bam

            fastq: !is_bam

        }
        .set { ch_input_reads }

    // Convert BAM to FASTQ if required
    def ch_bams = ch_input_reads.bam.map { meta, reads ->

        def read_list = reads instanceof List ? reads : [reads]

        [ meta, read_list[0] ]

    }

    SAMTOOLS_BAM2FASTQ ( ch_bams )

    ch_versions = ch_versions.mix(SAMTOOLS_BAM2FASTQ.out.versions)

    ch_fastqs = ch_input_reads.fastq.mix(SAMTOOLS_BAM2FASTQ.out.fastq)
    // 2. Align short reads to driver pangenome via CPU or GPU Giraffe
    if (params.enable_gpu) {
        PARABRICKS_VG_GIRAFFE ( ch_fastqs, ch_giraffe_index )
        ch_aligned_reads = PARABRICKS_VG_GIRAFFE.out.bam
        ch_versions      = ch_versions.mix(PARABRICKS_VG_GIRAFFE.out.versions)
    } else {
        VG_GIRAFFE ( ch_fastqs, ch_giraffe_index )
        ch_aligned_reads = VG_GIRAFFE.out.bam
        ch_versions      = ch_versions.mix(VG_GIRAFFE.out.versions)
    }

    // 3. Summarize read coverage on graph (vg pack)
    VG_PACK ( ch_aligned_reads, ch_giraffe_index )
    ch_versions = ch_versions.mix(VG_PACK.out.versions)

    // 4. Genotype variants (vg call)
    VG_CALL ( VG_PACK.out.pack, ch_giraffe_index )
    ch_versions = ch_versions.mix(VG_CALL.out.versions)

    // 5. Filter for somatic variants
    FILTER_SOMATIC_VARIANTS ( VG_CALL.out.vcf )
    ch_versions = ch_versions.mix(FILTER_SOMATIC_VARIANTS.out.versions)

    // 6. QC, Benchmark and report
    COLLECT_QC_REPORT ( FILTER_SOMATIC_VARIANTS.out.vcf )
    ch_versions = ch_versions.mix(COLLECT_QC_REPORT.out.versions)

    emit:
    aligned  = ch_aligned_reads               // channel: [ val(meta), path(bam) ]
    vcf      = FILTER_SOMATIC_VARIANTS.out.vcf// channel: [ val(meta), path(vcf), path(tbi) ]
    qc       = COLLECT_QC_REPORT.out.html     // channel: [ val(meta), path(html) ]
    versions = ch_versions                    // channel: [ path(versions.yml) ]
}
