/*
 * MODULE: VG_CALL
 * Purpose : Call and genotype variants from graph alignment coverage
 * Status  : complete implementation
 *
 * Container : Biocontainers vg 1.76.1
 *
 * Notes:
 *  - Calls genotypes from GBZ graph using .pack coverage file
 *  - Outputs gzipped VCF of graph-called variants
 */

process VG_CALL {
    tag "$meta.id"
    label 'process_high'

    container "quay.io/biocontainers/vg:1.76.1--h9ee0642_0"

    input:
    tuple val(meta), path(pack)
    tuple val(meta_idx), path(gbz), path(dist), path(min)

    output:
    tuple val(meta), path("*.vcf.gz"), emit: vcf
    path "versions.yml"              , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    vg call \\
        ${gbz} \\
        -k ${pack} \\
        -t ${task.cpus} \\
        ${args} | gzip -c > ${prefix}.vcf.gz

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        vg: \$(vg version 2>&1 | head -n 1 | sed 's/v//')
    END_VERSIONS
    """

    stub:
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    touch ${prefix}.vcf.gz

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        vg: \$(vg version 2>&1 | head -n 1 | sed 's/v//')
    END_VERSIONS
    """
}