/*
 * MODULE: VG_PACK
 * Purpose : summarize read alignments to graph
 * Status  : complete scaffold
 */

process VG_PACK {
    tag "$meta.id"
    label 'process_high'

    container "quay.io/biocontainers/vg:1.76.1--h9ee0642_0"

    input:
    tuple val(meta), path(aln)
    tuple val(meta_idx), path(gbz), path(dist), path(min)

    output:
    tuple val(meta), path("*.pack"), emit: pack
    path "versions.yml"            , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    def input_flag = aln.name.endsWith('.gaf') ? "-a ${aln}" : "-g ${aln}"
    """
    vg pack \\
        -x ${gbz} \\
        ${input_flag} \\
        -t ${task.cpus} \\
        -o ${prefix}.pack \\
        ${args}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        vg: \$(vg version 2>&1 | head -n 1 | sed 's/v//')
    END_VERSIONS
    """

    stub:
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    touch ${prefix}.pack

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        vg: \$(vg version 2>&1 | head -n 1 | sed 's/v//')
    END_VERSIONS
    """
}