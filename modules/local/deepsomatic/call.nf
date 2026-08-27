/*
 * MODULE: DEEPSOMATIC_CALL
 * Purpose : call
 * Status  : placeholder - not yet implemented
 * Assigned: to be assigned
 */

// NOTE: DO WE JUST WANT TO USE THE NF-CORE MODULE? https://github.com/nf-core/modules/blob/master/modules/nf-core/deepsomatic/main.nf

process DEEPSOMATIC_CALL {
    tag "$meta.id"
    label 'process_high'

    container "${workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container
        ? 'https://depot.galaxyproject.org/singularity/deepsomatic:1.7.0--py310h9ee0642_0'
        : 'biocontainers/deepsomatic:1.7.0--py310h9ee0642_0'}"

    // input:

    // output:

    script:
    """
    # TODO: implement graph construction
    """
}
