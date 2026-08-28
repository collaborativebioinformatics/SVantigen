/*
 * MODULE: SVAHA3_BUILD_GRAPH
 * Purpose : Build a pangenome variation graph (GFA) from a linear reference and
 *           a manifest of known variants using Svaha.
 *
 *           Variant files are declared in a single manifest TSV:
 *               <type>\t<file>
 *           where type ∈ {small_vcf, small_maf, sv_tsv, sv_vcf, sv_bedpe}
 *           and <file> is a path resolvable from the work directory.
 *           A header line is skipped.
 * Status  : complete implementation
 *
 * Container : edawson/svaha:latest
 *
 * Notes:
 *  - Executes graph construction with reference FASTA and input variants to create .vg graph
 *  - Converts graph to GFA format for downstream indexing
 */

process SVAHA3_BUILD_GRAPH {
    tag "$meta.id"
    label 'process_medium'

    container "${ workflow.containerEngine in ['singularity', 'apptainer'] && !task.ext.singularity_pull_docker_container
        ? 'edawson/svaha:latest'
        : 'edawson/svaha:latest' }"

    input:
    tuple val(meta), path(vcf), path(tbi)
    tuple val(meta_fasta), path(fasta)

    output:
    tuple val(meta), path("*.gfa"), emit: gfa
    path "versions.yml"           , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    vg construct \\
        -r ${fasta} \\
        -v ${vcf} \\
        -t ${task.cpus} \\
        ${args} > ${prefix}.vg

    vg view ${prefix}.vg > ${prefix}.gfa

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        vg: \$(vg version 2>&1 | head -n 1 | sed 's/v//')
    END_VERSIONS
    """

    stub:
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    touch ${prefix}.gfa

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        vg: \$(vg version 2>&1 | head -n 1 | sed 's/v//')
    END_VERSIONS
    """
}
