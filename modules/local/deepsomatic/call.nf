/*
 * MODULE: DEEPSOMATIC_CALL
 * Purpose : call
 * Status  : placeholder - not yet implemented
 * Assigned: to be assigned
 */

// NOTE: DO WE JUST WANT TO USE THE NF-CORE MODULE? https://github.com/nf-core/modules/blob/master/modules/nf-core/deepsomatic/main.nf

process DEEPSOMATIC_CALL {

    container "docker.io/google/deepsomatic:1.7.0"

    input:
    tuple val(meta), path(tumor_bam), path(tumor_bai), path(normal_bam), path(normal_bai)
    path reference
    path reference_fai

    output:
    tuple val(meta), path("${meta.id}.deepsomatic.vcf.gz"),     emit: vcf
    tuple val(meta), path("${meta.id}.deepsomatic.vcf.gz.tbi"), emit: tbi

    script:
    def args = task.ext.args ?: ''
    def normal_cmd = normal_bam ? "--in-normal-bam ${normal_bam}" : ""
    """
    pbrun deepsomatic \\
        --ref ${reference} \\
        --in-tumor-bam ${tumor_bam} \\
        ${normal_cmd} \\
        --out-variants ${meta.id}.deepsomatic.vcf.gz \\
        ${args}
    """

    
    """
    # TODO: implement graph construction
    """
}
