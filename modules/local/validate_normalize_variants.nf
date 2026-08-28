/*
 * MODULE: VALIDATE_NORMALIZE_VARIANTS
 * Purpose : Validate and normalize known driver SVs + known small somatic
 *           variants
 * Status  : complete scaffold
 */

process VALIDATE_NORMALIZE_VARIANTS {
    tag "$meta.id"
    label 'process_low'

    container "${ workflow.containerEngine in ['singularity', 'apptainer'] && !task.ext.singularity_pull_docker_container
        ? 'https://depot.galaxyproject.org/singularity/bcftools:1.20--h8b25389_1'
        : 'biocontainers/bcftools:1.20--h8b25389_1' }"

    input:
    tuple val(meta), path(vcf)

    output:
    tuple val(meta), path("*.normalized.vcf.gz"), path("*.normalized.vcf.gz.tbi"), emit: vcf
    path "versions.yml"                                                          , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    bcftools norm \\
        -m -any \\
        ${vcf} \\
        ${args} \\
        -O z -o ${prefix}.normalized.vcf.gz

    tabix -f -p vcf ${prefix}.normalized.vcf.gz

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        bcftools: \$(bcftools --version 2>&1 | head -n 1 | sed 's/bcftools //')
    END_VERSIONS
    """

    stub:
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    touch ${prefix}.normalized.vcf.gz
    touch ${prefix}.normalized.vcf.gz.tbi

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        bcftools: \$(bcftools --version 2>&1 | head -n 1 | sed 's/bcftools //')
    END_VERSIONS
    """
}
