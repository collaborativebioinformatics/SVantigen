/*
 * MODULE: SAMTOOLS_BAM2FASTQ
 * Purpose : convert bam back to fastq
 * Status  : placeholder - not yet implemented
 * Assigned: to be assigned
 */

// NOTE: DO WE JUST WANT TO USE THE NF-CORE MODULE? https://github.com/nf-core/modules/blob/master/modules/nf-core/samtools/bam2fq/main.nf

process SAMTOOLS_BAM2FASTQ {
    tag "$meta.id"
    label 'process_medium'

    container "${workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container
        ? 'https://community-cr-prod.seqera.io/docker/registry/v2/blobs/sha256/31/315d2445cd42b0f5512fa37965a9c59bc93ae8614b7d105150caece6c61e2e71/data'
        : 'community.wave.seqera.io/library/htslib_samtools_xz:1595ae0727655963'}"

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
