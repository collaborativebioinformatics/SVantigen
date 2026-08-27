/*
 * MODULE: PARABRICKS_DEEPSOMATIC_CALL
 * Purpose : GPU-accelerated somatic small variant calling from matched
 *           tumor/normal long-read BAMs.
 * Status  : placeholder - not yet implemented
 *
 * Container: nvcr.io/nvidia/clara/clara-parabricks:4.7.1-1
 * Docs: https://docs.nvidia.com/clara/parabricks/tool-reference/tools/deepsomatic
 */

process PARABRICKS_DEEPSOMATIC_CALL {
    label 'process_high'
    label 'process_gpu'

    container "nvcr.io/nvidia/clara/clara-parabricks:4.7.1-1"
    // containerOptions { workflow.containerEngine == 'singularity' ? '--nv' : '--gpus all' }

    input:
    tuple val(meta), path(tumor_bam), path(tumor_bai), path(normal_bam), path(normal_bai)
    path reference
    path reference_fai

    output:
    tuple val(meta), path("${meta.id}.deepsomatic.vcf.gz"),     emit: vcf
    tuple val(meta), path("${meta.id}.deepsomatic.vcf.gz.tbi"), emit: tbi

    script:

    """
    pbrun \\
        deepsomatic \\
        --ref ${reference} \\
        --in-tumor-bam ${tumor_bam} \\
        ${normal_cmd} \\
        --out-variants ${meta.id}.deepsomatic.vcf.gz \\
        ${args}
    """
}