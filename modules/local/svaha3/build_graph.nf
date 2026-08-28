/*
 * MODULE: SVAHA3_BUILD_GRAPH
 * Purpose : Build a pangenome variation graph (GFA) from a linear reference and
 *           a manifest of known variants.
 *
 *           Variant files are declared in a single manifest TSV:
 *               <type>\t<file>
 *           where type ∈ {small_vcf, small_maf, sv_tsv, sv_vcf, sv_bedpe}
 *           and <file> is a path resolvable from the work directory.
 *           A header line is skipped.
 *
 * Status  : implemented scaffold
 */

process SVAHA3_BUILD_GRAPH {
     tag "$meta.id"
     label 'process_medium'

    // Build from https://github.com/edawson/svaha (see svaha/Dockerfile)
    container "edawson/svaha:latest"

    publishDir "${params.outdir}/pangenome", mode: 'copy', enabled: params.outdir

    input:
    tuple val(meta), path(reference), path(reference_index), path(manifest)

    output:
    tuple val(meta), path("${meta.id}.gfa"), emit: gfa
    path "versions.yml"                      , emit: versions

    when:
    task.ext.when == null || task.ext.when

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

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        svaha3: "\$(svaha3 --version 2>&1 || echo 'unknown')"
    END_VERSIONS
    """

    stub:
    """
    touch ${meta.id}.gfa
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        svaha3: "0.0.1"
    END_VERSIONS
    """
}
