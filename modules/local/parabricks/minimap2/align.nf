/*
 * MODULE: PARABRICKS_MINIMAP2_ALIGN
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

process PARABRICKS_MINIMAP2_ALIGN {
    tag "$meta.id"
    label 'process_high'
    label 'process_gpu'

    container "nvcr.io/nvidia/clara/clara-parabricks:4.7.1-1"

    input:
    tuple val(meta), path(reads)
    tuple val(meta_fasta), path(fasta)

    output:
    tuple val(meta), path("*.bam"),     emit: bam
    tuple val(meta), path("*.bam.bai"), emit: bai
    path "versions.yml"               , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def preset = task.ext.preset ?: 'map-pbmm2'
    def args   = task.ext.args   ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    pbrun minimap2 \\
        --ref ${fasta} \\
        --in-fq ${reads} \\
        --out-bam ${prefix}.bam \\
        --preset ${preset} \\
        --num-threads ${task.cpus} \\
        ${args}

    samtools index ${prefix}.bam

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        parabricks: "4.7.1-1"
    END_VERSIONS
    """

    stub:
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    touch ${prefix}.bam
    touch ${prefix}.bam.bai

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        parabricks: "4.7.1-1"
    END_VERSIONS
    """
}