/*
 * MODULE: SVAHA3_BUILD_GRAPH
 * Purpose : Build the cancer driver + recurrent neoantigen pangenome graph
 *           (GFA format) from the normalized driver SVs and small somatic
 *           variants, relative to a linear reference.
 * Status  : placeholder - not yet implemented
 * Assigned: to be assigned
 */

process SVAHA3_BUILD_GRAPH {

    container // create container from Svaha repository (https://github.com/edawson/svaha)

    input:
    path reference_fasta
    path normalized_driver_svs
    path normalized_small_variants

    output:
    path "pangenome.gfa", emit: pangenome_gfa

    script:
    """
    # TODO: implement graph construction
    """
}
