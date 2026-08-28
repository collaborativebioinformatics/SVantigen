/*
 * MODULE: PARABRICKS_PANGENOME_AWARE_DEEPVARIANT_CALL
 * Purpose : GPU-accelerated pangenome-aware DeepVariant variant calling
 *           from a pangenome reference (GBZ) and an input BAM, producing a VCF.
 * Status  : implemented
 *
 * Container: nvcr.io/nvidia/clara/clara-parabricks:4.7.1-1
 * Docs: https://docs.nvidia.com/clara/parabricks/tool-reference/tools/pangenome_aware_deepvariant
 */

process PARABRICKS_PANGENOME_AWARE_DEEPVARIANT_CALL {
    label 'process_high'
    label 'process_gpu'

    container "nvcr.io/nvidia/clara/clara-parabricks:4.7.1-1"
    // containerOptions { workflow.containerEngine == 'singularity' ? '--nv' : '--gpus all' }

    input:
    tuple val(meta), path(reference), path(pangenome), path(bam)

    output:
    tuple val(meta), path("${meta.id}.vcf.gz"), emit: vcf
    tuple val(meta), path("${meta.id}.vcf.gz.tbi"), emit: tbi

    script:
    def sbx   = task.ext.sbx ? '--sbx' : ''
    def args  = task.ext.args ?: ''
    """
    pbrun \\
        pangenome_aware_deepvariant \\
        --ref ${reference} \\
        --pangenome ${pangenome} \\
        --in-bam ${bam} \\
        --out-variants ${meta.id}.vcf.gz \\
        ${sbx} \\
        ${args}
    """
}
