/*
 * MODULE: PARABRICKS_MINIMAP2_ALIGN
 * Purpose : GPU-accelerated long-read alignment (minimap2 + KSW2 on GPU)
 * Status  : complete scaffold
 */

process PARABRICKS_MINIMAP2_ALIGN {
    tag "$meta.id"
    label 'process_high'
    label 'process_gpu'

    container "nvcr.io/nvidia/clara/clara-parabricks:4.7.1-1"

    input:
    tuple val(meta), path(reads)
    tuple val(meta_fasta), path(fasta)

    output:
    tuple val(meta), path("*.bam"), emit: bam
    path "versions.yml"           , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    pbrun minimap2 --ref ${fasta} --in-fq ${reads} --out-bam ${prefix}.bam

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        parabricks: "4.7.1-1"
    END_VERSIONS
    """

    stub:
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    touch ${prefix}.bam

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        parabricks: "4.7.1-1"
    END_VERSIONS
    """
}