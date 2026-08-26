/*
 * MODULE: VG_AUTOINDEX
 * Purpose : Build the giraffe-compatible index set from a GFA graph:
 *             - GBZ graph (vg's binary pangenome graph format)
 *             - distance index (.dist)
 *             - minimizer index (.shortread.withzip.min)
 *             - zipcodes (.shortread.zipcodes)
 * Status  : implemented
 *
 * Container: vg v1.76.1
 * Docs: https://docs.nvidia.com/clara/parabricks/tool-reference/tools/giraffe
 */

process VG_AUTOINDEX {

    container "${workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container
        ? 'https://depot.galaxyproject.org/singularity/vg:1.76.1--h9ee0642_0'
        : 'biocontainers/vg:1.76.1--h9ee0642_0'}"

    publishDir "${params.outdir}/pangenome", mode: 'copy', enabled: params.outdir

    input:
    tuple val(meta), path(gfa)

    output:
    tuple val(meta), path("${meta.id}.gbz"),                    emit: gbz
    tuple val(meta), path("${meta.id}.dist"),                   emit: dist
    tuple val(meta), path("${meta.id}.shortread.withzip.min"),  emit: min
    tuple val(meta), path("${meta.id}.shortread.zipcodes"),     emit: zipcodes

    script:
    def args = task.ext.args ?: ''
    """
    vg autoindex \\
        -p ${meta.id} \\
        -g ${gfa} \\
        -w giraffe \\
        ${args}
    """
}
