/*
 * MODULE: MINIMAP2_ALIGN
 * Purpose : CPU long-read alignment with minimap2, coordinate-sorted BAM output
 * Status  : implemented
 *
 * Container: minimap2 + samtools
 * Nf-core Module: https://github.com/nf-core/modules/blob/master/modules/nf-core/minimap2/align/main.nf
 */

process MINIMAP2_ALIGN {

    container "${workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container
        ? 'https://community-cr-prod.seqera.io/docker/registry/v2/blobs/sha256/37/37671219cfd244eb9b33db9345d3543ffd83037419a1c57f4648aace493ec2c2/data'
        : 'community.wave.seqera.io/library/minimap2_samtools:b09096fc890429ce' }"

    input:
    tuple val(meta), path(reference), path(reads)

    output:
    tuple val(meta), path("${meta.id}.bam"),    emit: bam
    tuple val(meta), path("${meta.id}.bam.bai"), emit: bai

    script:
    def preset = task.ext.preset ?: 'map-pbmm2'
    def args   = task.ext.args   ?: ''
    """
    minimap2 \\
        -ax ${preset} \\
        ${args} \\
        ${reference} \\
        ${reads} | \\
    samtools sort -@ ${task.cpus} -o ${meta.id}.bam

    samtools index ${meta.id}.bam
    """
}
