/*
 * MODULE: VG_GIRAFFE
 * Purpose : align to pangenome
 * Status  : placeholder - not yet implemented
 * Assigned: to be assigned
 */

process VG_GIRAFFE {
    tag "$meta.id"
    label 'process_high'

    container "${workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container
        ? 'https://depot.galaxyproject.org/singularity/vg:1.76.1--h9ee0642_0'
        : 'biocontainers/vg:1.76.1--h9ee0642_0'}"

    input:
    tuple val(meta), path(reads)
    tuple val(meta_idx), path(gbz), path(dist), path(min)

    output:
    tuple val(meta), path("*.bam"), emit: bam
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
        -o BAM \\
        ${args} > ${prefix}.bam

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        vg: \$(vg version 2>&1 | head -n 1 | sed 's/v//')
    END_VERSIONS
    """

    stub:
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    touch ${prefix}.bam

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        vg: \$(vg version 2>&1 | head -n 1 | sed 's/v//')
    END_VERSIONS
    """
}