/*
 * MODULE: PARABRICKS_DEEPSOMATIC_CALL
 * Purpose : GPU-accelerated somatic small variant calling from matched
 *           tumor/normal long-read BAMs using NVIDIA Parabricks.
 * Status  : implemented
 *
 * Container: nvcr.io/nvidia/clara/clara-parabricks:4.7.1-1
 * Docs: https://docs.nvidia.com/clara/parabricks/tool-reference/tools/deepsomatic
 */

process PARABRICKS_DEEPSOMATIC_CALL {
    tag "$meta.id"
    label 'process_high'
    label 'process_gpu'

    container "nvcr.io/nvidia/clara/clara-parabricks:4.7.1-1"

    input:
    tuple val(meta), path(bam)
    tuple val(meta_fasta), path(fasta)

    output:
    tuple val(meta), path("*.vcf.gz"), emit: vcf
    path "versions.yml"              , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    pbrun deepsomatic --ref ${fasta} --in-bam ${bam} --out-vcf ${prefix}.vcf.gz

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        parabricks: "4.7.1-1"
    END_VERSIONS
    """

    stub:
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    touch ${prefix}.vcf.gz

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        parabricks: "4.7.1-1"
    END_VERSIONS
    """
}