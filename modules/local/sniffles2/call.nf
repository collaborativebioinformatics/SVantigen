/*
 * MODULE: SNIFFLES2_CALL
 * Purpose : Call structural variants from long-read alignments (PacBio HiFi / Nanopore)
 *           using Sniffles2.
 * Docs    : https://github.com/fritzsedlazeck/Sniffles
 * Nf-core : https://github.com/nf-core/modules/blob/master/modules/nf-core/sniffles/main.nf
 */

process SNIFFLES2_CALL {
    tag "$meta.id"
    label 'process_high'

    container "${ workflow.containerEngine in ['singularity', 'apptainer'] && !task.ext.singularity_pull_docker_container
        ? 'https://community-cr-prod.seqera.io/docker/registry/v2/blobs/sha256/a3/a392a64ae046bd1b8679f2ae590f88d84fed26d569ab70810df969741722dbcc/data'
        : 'community.wave.seqera.io/library/sniffles:2.8.0--c25a97c10afa095a' }"

    input:
    tuple val(meta), path(bam), path(bai)
    tuple val(meta2), path(fasta)
    tuple val(meta3), path(tandem_file)

    output:
    tuple val(meta), path("*.vcf.gz")    , emit: vcf
    tuple val(meta), path("*.vcf.gz.tbi"), emit: tbi, optional: true
    tuple val(meta), path("*.snf")       , emit: snf, optional: true
    path "versions.yml"                  , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args           = task.ext.args ?: ''
    def prefix         = task.ext.prefix ?: "${meta.id}"
    def reference      = fasta ? "--reference ${fasta}" : ""
    def tandem_repeats = (tandem_file && tandem_file.name != 'NO_FILE') ? "--tandem-repeats ${tandem_file}" : ''

    """
    sniffles \\
        --input ${bam} \\
        ${reference} \\
        --threads ${task.cpus} \\
        ${tandem_repeats} \\
        --vcf ${prefix}.vcf.gz \\
        --snf ${prefix}.snf \\
        ${args}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        sniffles: \$(sniffles --version | sed 's/.* //g')
    END_VERSIONS
    """

    stub:
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    echo "" | gzip > ${prefix}.vcf.gz
    touch ${prefix}.vcf.gz.tbi
    touch ${prefix}.snf

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        sniffles: 2.8.0
    END_VERSIONS
    """
}

