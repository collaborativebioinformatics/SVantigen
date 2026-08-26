/*
 * MODULE: VG_AUTOINDEX
 * Purpose : Build the giraffe-compatible index set (GBZ, distance, minimizer,
 *           etc.) from the cancer SV pangenome so it can be used for
 *           short-read alignment in the CALL_RECURRENT_VARIANTS subworkflow.
 * Status  : placeholder - not yet implemented
 * Assigned: to be assigned
 */

process VG_AUTOINDEX {

    // container "quay.io/vgteam/vg:v1.76.1"
    container "${workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container
        ? 'https://depot.galaxyproject.org/singularity/vg:1.76.1--h9ee0642_0'
        : 'biocontainers/vg:1.76.1--h9ee0642_0'}"

    input:
    path pangenome_gfa

    output:
    path "giraffe_indexes/*", emit: giraffe_indexes

    script:
    """
    # TODO: implement indexing
    """
}