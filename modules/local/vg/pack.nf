/*
 * MODULE: VG_PACK
 * Purpose : summarize read alignments to graph
 * Status  : placeholder - not yet implemented
 * Assigned: to be assigned
 */

process VG_PACK {

    // container "quay.io/vgteam/vg:v1.76.1"
    container "${workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container
        ? 'https://depot.galaxyproject.org/singularity/vg:1.76.1--h9ee0642_0'
        : 'biocontainers/vg:1.76.1--h9ee0642_0'}"

    // input:

    // output:

    script:
    """
    # TODO: implement indexing
    """
}