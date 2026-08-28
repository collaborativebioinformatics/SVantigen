/*
 * MODULE: VG_GIRAFFE
 * Purpose : align to pangenome
 * Status  : complete scaffold
 */

process VG_GIRAFFE {
    tag "$meta.id"
    label 'process_high'

    container "quay.io/biocontainers/vg:1.76.1--h9ee0642_0"

    input:
    tuple val(meta), path(reads)
    tuple val(meta_idx), path(gbz), path(dist), path(min)

    output:
    tuple val(meta), path("*.gam"), emit: gam
    path "versions.yml"           , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    def fastq_args = (reads instanceof List && reads.size() > 1) ? "-f ${reads[0]} -f ${reads[1]}" : "-f ${reads}"
    """
    vg giraffe \\
        -Z ${gbz} \\
        -d ${dist} \\
        -m ${min} \\
        ${fastq_args} \\
        -t ${task.cpus} \\
        -o GAM \\
        ${args} > ${prefix}.gam

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        vg: \$(vg version 2>&1 | head -n 1 | sed 's/v//')
    END_VERSIONS
    """

    stub:
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    touch ${prefix}.gam

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        vg: \$(vg version 2>&1 | head -n 1 | sed 's/v//')
    END_VERSIONS
    """
}