/*
 * MODULE: VG_AUTOINDEX
 * Purpose : Build the giraffe-compatible index set (GBZ, distance, minimizer,
 *           etc.) from the cancer SV pangenome so it can be used for
 *           short-read alignment in the CALL_RECURRENT_VARIANTS subworkflow.
 * Status  : placeholder - not yet implemented
 * Assigned: to be assigned
 */

process VG_AUTOINDEX {
    tag "$meta.id"
    label 'process_high'

    container "${workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container
        ? 'https://depot.galaxyproject.org/singularity/vg:1.76.1--h9ee0642_0'
        : 'biocontainers/vg:1.76.1--h9ee0642_0'}"

    input:
    tuple val(meta), path(gfa)

    output:
    tuple val(meta), path("*.giraffe.gbz"), path("*.dist"), path("*.min"), emit: index
    path "versions.yml"                                                   , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    vg autoindex \\
        --workflow giraffe \\
        --gfa ${gfa} \\
        --prefix ${prefix} \\
        --threads ${task.cpus} \\
        ${args}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        vg: \$(vg version 2>&1 | head -n 1 | sed 's/v//')
    END_VERSIONS
    """

    stub:
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    touch ${prefix}.giraffe.gbz
    touch ${prefix}.dist
    touch ${prefix}.min

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        vg: \$(vg version 2>&1 | head -n 1 | sed 's/v//')
    END_VERSIONS
    """
}