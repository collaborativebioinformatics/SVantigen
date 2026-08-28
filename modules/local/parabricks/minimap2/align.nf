/*
 * MODULE: PARABRICKS_MINIMAP2_ALIGN
 * Purpose : GPU-accelerated long-read alignment (minimap2 + KSW2 on GPU),
 *           coordinate-sorted BAM output.
 * Status  : implemented
 *
 * Container: nvcr.io/nvidia/clara/clara-parabricks:4.7.1-1
 * Docs: https://docs.nvidia.com/clara/parabricks/tool-reference/tools/minimap2
 * Nf-core Module: https://github.com/nf-core/modules/blob/master/modules/nf-core/parabricks/minimap2/main.nf
 */

process PARABRICKS_MINIMAP2_ALIGN {
    label 'process_high'
    label 'process_gpu'

    container "nvcr.io/nvidia/clara/clara-parabricks:4.7.1-1"
    // containerOptions { workflow.containerEngine == 'singularity' ? '--nv' : '--gpus all' }

    input:
    tuple val(meta), path(reference), path(fastq)

    output:
    tuple val(meta), path("${meta.id}.bam"),    emit: bam
    tuple val(meta), path("${meta.id}.bam.bai"), emit: bai

    script:
    def args = task.ext.args ?: ''
    """
    pbrun \\
        minimap2 \\
        --ref ${reference} \\
        --in-fq ${fastq} \\
        --out-bam ${meta.id}.bam \\
        ${args}
    """
}