/*
 * MODULE: SAMTOOLS_FAIDX
 * Purpose : Index FASTA reference sequence with samtools faidx
 * Status  : complete implementation
 *
 * Container : Wave / Biocontainers samtools
 *
 * Notes:
 *  - Generates .fai index file for input reference FASTA
 *  - Required downstream by variant callers such as DeepSomatic
 */

process SAMTOOLS_FAIDX {
    tag "$meta.id"
    label 'process_single'

    container "community.wave.seqera.io/library/minimap2_samtools:b09096fc890429ce"

    input:
    tuple val(meta), path(fasta)

    output:
    tuple val(meta), path(fasta), path("*.fai"), emit: fa_fai
    path "versions.yml"                        , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    """
    samtools faidx ${fasta}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        samtools: \$(echo \$(samtools --version 2>&1) | sed 's/^.*samtools //; s/Using.*\$//')
    END_VERSIONS
    """

    stub:
    """
    touch ${fasta}.fai

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        samtools: 1.20
    END_VERSIONS
    """
}
