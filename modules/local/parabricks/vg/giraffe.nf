/*
 * MODULE: PARABRICKS_VG_GIRAFFE
 * Purpose : GPU-accelerated pangenome alignment (vg giraffe) + coordinate
 *           sort, replacing plain `vg giraffe | gatk SortSam`.
 * Status  : placeholder - not yet implemented
 *
 * Container: nvcr.io/nvidia/clara/clara-parabricks:4.7.1-1
 * Docs: https://docs.nvidia.com/clara/parabricks/tool-reference/tools/giraffe#compatible-cpu-based-vg-giraffe-and-gatk4-commands
 */

process PARABRICKS_VG_GIRAFFE {
    label 'process_high'
    label 'process_gpu'

    container "nvcr.io/nvidia/clara/clara-parabricks:4.7.1-1"
    // containerOptions { workflow.containerEngine == 'singularity' ? '--nv' : '--gpus all' }

    // input:

    // output:

    script:
    """
    pbrun \\
        giraffe \\

    """
}