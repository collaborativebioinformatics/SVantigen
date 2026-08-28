/*
 * MODULE: COLLECT_QC_REPORT
 * Purpose : collect qc report
 * Status  : complete scaffold
 */

process COLLECT_QC_REPORT {
    tag "$meta.id"
    label 'process_low'

    container "${ workflow.containerEngine in ['singularity', 'apptainer'] && !task.ext.singularity_pull_docker_container
        ? 'https://depot.galaxyproject.org/singularity/bcftools:1.20--h8b25389_1'
        : 'biocontainers/bcftools:1.20--h8b25389_1' }"

    input:
    tuple val(meta), path(vcf), path(tbi)

    output:
    tuple val(meta), path("*.html"), emit: html
    path "versions.yml"            , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    bcftools stats ${vcf} > ${prefix}_bcftools_stats.txt

    cat <<-EOF > ${prefix}_qc_report.html
    <html>
    <head><title>SVantigen QC Report - ${meta.id}</title></head>
    <body>
    <h1>QC Report for ${meta.id}</h1>
    <pre>
    \$(cat ${prefix}_bcftools_stats.txt)
    </pre>
    </body>
    </html>
    EOF

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        bcftools: \$(bcftools --version 2>&1 | head -n 1 | sed 's/bcftools //')
    END_VERSIONS
    """

    stub:
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    touch ${prefix}_qc_report.html

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        bcftools: \$(bcftools --version 2>&1 | head -n 1 | sed 's/bcftools //')
    END_VERSIONS
    """
}
