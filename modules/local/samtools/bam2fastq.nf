/*
 * MODULE: SAMTOOLS_BAM2FASTQ
 * Purpose : Convert aligned BAM files back to FASTQ format for downstream re-alignment
 * Status  : complete implementation
 *
 * Container : Galaxy / Biocontainers samtools 1.20
 *
 * Notes:
 *  - Uses samtools collate and samtools fastq to stream collated reads into gzipped FASTQ
 *  - Output paired or single-end FASTQ channels
 */

process SAMTOOLS_BAM2FASTQ {
    tag "$meta.id"
    label 'process_medium'

    container "${workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container
        ? 'https://depot.galaxyproject.org/singularity/samtools:1.20--h50ea8bc_0'
        : 'biocontainers/samtools:1.20--h50ea8bc_0'}"

    input:
    tuple val(meta), path(bam)

    output:
    tuple val(meta), path("*.fastq.gz"), emit: fastq
    path "versions.yml"                , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    samtools collate -u -O -@ ${task.cpus} ${bam} | \\
    samtools fastq -1 ${prefix}_1.fastq.gz -2 ${prefix}_2.fastq.gz -0 /dev/null -s /dev/null -@ ${task.cpus} ${args} -

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        samtools: \$(echo \$(samtools --version 2>&1) | sed 's/^.*samtools //; s/Using.*\$//')
    END_VERSIONS
    """

    stub:
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    touch ${prefix}_1.fastq.gz
    touch ${prefix}_2.fastq.gz

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        samtools: \$(echo \$(samtools --version 2>&1) | sed 's/^.*samtools //; s/Using.*\$//')
    END_VERSIONS
    """
}
