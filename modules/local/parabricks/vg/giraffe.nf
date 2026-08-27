/*
 * MODULE: PARABRICKS_VG_GIRAFFE
 * Purpose : GPU-accelerated pangenome alignment (vg giraffe) + coordinate
 *           sort, replacing plain `vg giraffe | gatk SortSam`.
 * Status  : placeholder - not yet implemented
 *
 * Container: nvcr.io/nvidia/clara/clara-parabricks:4.7.1-1
 * Docs: https://docs.nvidia.com/clara/parabricks/tool-reference/tools/giraffe#compatible-cpu-based-vg-giraffe-and-gatk4-commands
 */

process PARABRICKS_VG_GIRAFFE {
    tag "$meta.id"
    label 'process_high'
    label 'process_gpu'

    container "nvcr.io/nvidia/clara/clara-parabricks:4.7.1-1"

    input:
    tuple val(meta), path(reads)
    tuple val(meta_idx), path(gbz), path(dist), path(min)

    output:
    tuple val(meta), path("*.sorted.bam"), emit: bam
    tuple val(meta), path("*.sorted.bam.bai"), emit: bai
    path "versions.yml"                  , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    def read_input = (reads instanceof List && reads.size() > 1) ? "--in-fq ${reads[0]} ${reads[1]}" : "--in-se-fq ${reads}"
    """
    pbrun giraffe \\
        --gbz-index ${gbz} \\
        --dist-index ${dist} \\
        --min-index ${min} \\
        ${read_input} \\
        --out-bam ${prefix}.sorted.bam \\
        ${args}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        parabricks: \$(pbrun version 2>&1 | head -n 1 | sed 's/pbrun //')
    END_VERSIONS
    """

    stub:
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    touch ${prefix}.sorted.bam
    touch ${prefix}.sorted.bam.bai

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        parabricks: "4.7.1-1"
    END_VERSIONS
    """
}