/*
 * MODULE: MINIMAP2_ALIGN
 * Purpose : CPU long-read alignment with minimap2, coordinate-sorted BAM output
 * Status  : complete implementation
 *
 * Container : Wave / Biocontainers minimap2 + samtools
 * Nf-core precursor (CPU): https://github.com/nf-core/modules/blob/master/modules/nf-core/minimap2/align/main.nf
 *
 * Notes:
 *  - Align long reads (ONT / PacBio) to reference genome using minimap2 -ax map-ont
 *  - Sorts alignment using samtools sort and produces indexed .bam + .bai output
 */

process MINIMAP2_ALIGN {
    tag "$meta.id"
    label 'process_high'

    container "community.wave.seqera.io/library/minimap2_samtools:b09096fc890429ce"

    input:
    tuple val(meta), path(reads)
    tuple val(meta_fasta), path(fasta)

    output:
    tuple val(meta), path("*.bam"),     emit: bam
    tuple val(meta), path("*.bam.bai"), emit: bai
    path "versions.yml"               , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def preset = task.ext.preset ?: 'map-ont'
    def args   = task.ext.args   ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    minimap2 \\
        -ax ${preset} \\
        ${args} \\
        ${fasta} \\
        ${reads} | \\
    samtools sort -@ ${task.cpus} -o ${prefix}.bam

    samtools index ${prefix}.bam

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        minimap2: \$(minimap2 --version 2>&1)
        samtools: \$(echo \$(samtools --version 2>&1) | sed 's/^.*samtools //; s/Using.*\$//')
    END_VERSIONS
    """

    stub:
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    touch ${prefix}.bam
    touch ${prefix}.bam.bai

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        minimap2: \$(minimap2 --version 2>&1)
        samtools: \$(echo \$(samtools --version 2>&1) | sed 's/^.*samtools //; s/Using.*\$//')
    END_VERSIONS
    """
}
