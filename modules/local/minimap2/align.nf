/*
 * MODULE: MINIMAP2_ALIGN
 * Purpose : GPU-accelerated long-read alignment with NVIDIA Parabricks minimap2,
 *           coordinate-sorted BAM output (drop-in GPU replacement for the CPU
 *           minimap2 + samtools sort/index pipeline)
 * Status  : implemented
 *
 * Container : NVIDIA Clara Parabricks (bundles GPU minimap2 + samtools)
 * Docs      : https://docs.nvidia.com/clara/parabricks/tool-reference/tools/minimap2
 * Nf-core precursor (CPU): https://github.com/nf-core/modules/blob/master/modules/nf-core/minimap2/align/main.nf
 *
 * Notes:
 *  - pbrun minimap2 replaces the `minimap2 -ax ... | samtools sort` pipe with a
 *    single GPU-accelerated call that writes a coordinate-sorted BAM directly.
 *  - `--preset` values differ slightly from vanilla minimap2 but 'map-pbmm2'
 *    (the default here) is still supported and reproduces pbmm2-style output.
 *  - Requires GPU access at container runtime: Docker needs `--gpus all`,
 *    Singularity/Apptainer needs `--nv`. This is wired via `containerOptions`
 *    and the `accelerator` directive so it plays nicely with Slurm/HPC GPU
 *    scheduling (e.g. `--gres=gpu:1`).
 *  - `.bai` is produced with `samtools index`, which ships in the same
 *    Parabricks container, so no extra container/module is needed.
 *  - Double-check for HPC setup: Parabricks licensing and container access (NGC registry auth) may require credentials distinct 
 *    from your usual Seqera/Wave container pulls — confirm your cluster's Singularity/Apptainer build has NGC access before running this at scale.
 */

process MINIMAP2_ALIGN {

    label 'gpu'

    // Request 1 GPU by default; override via process-level `accelerator` config
    // (e.g. accelerator 2, type: 'nvidia-tesla-a100') or task.ext in nextflow.config
    accelerator 1, type: task.ext.gpuType ?: null

    container "${workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container
        ? 'https://depot.galaxyproject.org/singularity/clara-parabricks:4.7.1-1'
        : 'nvcr.io/nvidia/clara/clara-parabricks:4.7.1-1' }"

    // GPU device access at runtime
    containerOptions {
        workflow.containerEngine == 'singularity' ? '--nv' : '--gpus all'
    }

    input:
    tuple val(meta), path(reference), path(reads)

    output:
    tuple val(meta), path("${meta.id}.bam"),     emit: bam
    tuple val(meta), path("${meta.id}.bam.bai"), emit: bai

    script:
    def preset  = task.ext.preset  ?: 'map-pbmm2'
    def args    = task.ext.args    ?: ''
    def numGpus = task.ext.numGpus ?: (task.accelerator?.request ?: 1)
    """
    pbrun minimap2 \\
        --ref ${reference} \\
        --in-fq ${reads} \\
        --out-bam ${meta.id}.bam \\
        --preset ${preset} \\
        --num-gpus ${numGpus} \\
        --num-threads ${task.cpus} \\
        ${args}

    samtools index ${meta.id}.bam
    """
}
