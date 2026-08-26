/*
 * MODULE: SNIFFLES2_CALL
 * Purpose : call
 * Status  : placeholder - not yet implemented
 * Assigned: to be assigned
 */

// NOTE: DO WE JUST WANT TO USE THE NF-CORE MODULE? https://github.com/nf-core/modules/blob/master/modules/nf-core/sniffles/main.nf

process SNIFFLES2_CALL {

    container "${workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container
        ? 'https://community-cr-prod.seqera.io/docker/registry/v2/blobs/sha256/a3/a392a64ae046bd1b8679f2ae590f88d84fed26d569ab70810df969741722dbcc/data'
        : 'community.wave.seqera.io/library/sniffles:2.8.0--c25a97c10afa095a' }"

    // input:

    // output:

    script:
    """
    # TODO: implement graph construction
    """
}
