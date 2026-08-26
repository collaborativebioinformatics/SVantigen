/*
 * MODULE: SAMTOOLS_BAM2FASTQ
 * Purpose : convert bam back to fastq
 * Status  : placeholder - not yet implemented
 * Assigned: to be assigned
 */

// NOTE: DO WE JUST WANT TO USE THE NF-CORE MODULE? https://github.com/nf-core/modules/blob/master/modules/nf-core/samtools/bam2fq/main.nf

process SAMTOOLS_BAM2FASTQ {

    container "${workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container
        ? 'https://community-cr-prod.seqera.io/docker/registry/v2/blobs/sha256/31/315d2445cd42b0f5512fa37965a9c59bc93ae8614b7d105150caece6c61e2e71/data'
        : 'community.wave.seqera.io/library/htslib_samtools_xz:1595ae0727655963'}"

    // input:

    // output:

    script:
    """
    # TODO: implement graph construction
    """
}
