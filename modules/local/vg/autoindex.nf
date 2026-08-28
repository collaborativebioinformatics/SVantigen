/*
 * MODULE: VG_AUTOINDEX
 * Purpose : Build giraffe-compatible index set (GBZ graph, distance, minimizer) from GFA
 * Status  : complete implementation
 *
 * Container : Biocontainers vg 1.76.1
 *
 * Notes:
 *  - Runs vg autoindex --workflow giraffe on input GFA pangenome
 *  - Generates .gbz (GBZ graph), .dist (distance index), and .min (minimizer index)
 */

process VG_AUTOINDEX {
    tag "$meta.id"
    label 'process_high'

    container "quay.io/biocontainers/vg:1.76.1--h9ee0642_0"

    input:
    tuple val(meta), path(gfa)

    output:
    tuple val(meta), path("*.gbz"), path("*.dist"), path("*.min"), emit: index
    path "versions.yml"                                           , emit: versions

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
    touch ${prefix}.gbz
    touch ${prefix}.dist
    touch ${prefix}.min

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        vg: \$(vg version 2>&1 | head -n 1 | sed 's/v//')
    END_VERSIONS
    """
}
