/*
 * MODULE: MINIMAP2_ALIGN
 * Purpose : align
 * Status  : placeholder - not yet implemented
 * Assigned: to be assigned
 */

// NOTE: DO WE JUST WANT TO USE THE NF-CORE MODULE? https://github.com/nf-core/modules/blob/master/modules/nf-core/minimap2/align/main.nf

process MINIMAP2_ALIGN {

    container "${workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container
        ? 'https://community-cr-prod.seqera.io/docker/registry/v2/blobs/sha256/37/37671219cfd244eb9b33db9345d3543ffd83037419a1c57f4648aace493ec2c2/data'
        : 'community.wave.seqera.io/library/minimap2_samtools:b09096fc890429ce' }"

    // input:

    // output:

    script:
    """
    # TODO: implement graph construction
    """
}
