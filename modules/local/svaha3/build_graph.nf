<<<<<<< HEAD
/*
 * MODULE: SVAHA3_BUILD_GRAPH
 * Purpose : Build the cancer driver + recurrent neoantigen pangenome graph
 *           (GFA format) from the normalized driver SVs and small somatic
 *           variants, relative to a linear reference.
 * Status  : placeholder - not yet implemented
 * Assigned: to be assigned
 */

process SVAHA3_BUILD_GRAPH {
    tag "$meta.id"
    label 'process_medium'

    container "${workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container
        ? 'https://depot.galaxyproject.org/singularity/vg:1.76.1--h9ee0642_0'
        : 'biocontainers/vg:1.76.1--h9ee0642_0'}"

    input:
    tuple val(meta), path(vcf)
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
=======
/*
 * MODULE: SVAHA3_BUILD_GRAPH
 * Purpose : Build a pangenome variation graph (GFA) from a linear reference and
 *           a set of known variants, relative to a linear reference.
 *
 *           Variant files are declared in a single manifest TSV:
 *               <type>\t<file>
 *           where type ∈ {small_vcf, small_maf, sv_tsv, sv_vcf, sv_bedpe}
 *           and <file> is a path resolvable from the work directory.
 *           A header line (anything) is skipped.
 *
 * Status  : implemented
 *
 * Container: build from https://github.com/edawson/svaha (see svaha/Dockerfile)
 */

process SVAHA3_BUILD_GRAPH {

    // Build from https://github.com/edawson/svaha (see svaha/Dockerfile)
    container "edawson/svaha:latest"

    publishDir "${params.outdir}/pangenome", mode: 'copy', enabled: params.outdir

    input:
    tuple val(meta), path(reference), path(reference_index), path(manifest)

    output:
    tuple val(meta), path("${meta.id}.gfa"), emit: gfa

    script:
    def args = task.ext.args ?: ''
    """
    # Build svaha3 args from the manifest (type<TAB>file, with a header row).
    svaha_args=""
    while IFS=\$'\\t' read -r type file; do
        case "\$type" in
            small_vcf) svaha_args="\$svaha_args --small-vcf \$file" ;;
            small_maf) svaha_args="\$svaha_args --small-maf \$file" ;;
            sv_tsv)    svaha_args="\$svaha_args --sv-tsv \$file" ;;
            sv_vcf)    svaha_args="\$svaha_args --sv-vcf \$file" ;;
            sv_bedpe)  svaha_args="\$svaha_args --sv-bedpe \$file" ;;
        esac
    done < <(tail -n +2 ${manifest})

    svaha3 build-graph \\
        --reference ${reference} \\
        --reference-index ${reference_index} \\
        \$svaha_args \\
        --output-graph ${meta.id}.gfa \\
        ${args}
    """
}
>>>>>>> origin/main
