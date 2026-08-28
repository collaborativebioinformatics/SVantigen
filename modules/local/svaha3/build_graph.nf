/*
 * MODULE: SVAHA3_BUILD_GRAPH
 * Purpose : Build a pangenome variation graph (GFA) directly from a linear reference
 *           and input variants (VCF) using Svaha.
 * Status  : complete implementation
 *
 * Container : edawson/svaha:latest
 *
 * Notes:
 *  - Uncompresses gzipped VCF input if necessary for svaha VCF parser compatibility
 *  - Converts GFA 2.0 (S/E/O lines) emitted by svaha to GFA 1.0 (S/L/P lines) for vg autoindex compatibility
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
    VCF_FILE="${vcf}"
    if [[ "${vcf}" == *.gz ]]; then
        gzip -dc ${vcf} > input_uncompressed.vcf
        VCF_FILE="input_uncompressed.vcf"
    fi

    svaha \\
        -r ${fasta} \\
        -v \${VCF_FILE} \\
        ${args} | awk '
        BEGIN { FS="\\t"; OFS="\\t" }
        {
            if (\$1 == "H") {
                print "H\\tVN:Z:1.0"
            } else if (\$1 == "S") {
                print "S", \$2, \$4
            } else if (\$1 == "E") {
                n1 = substr(\$3, 1, length(\$3)-1)
                o1 = substr(\$3, length(\$3), 1)
                n2 = substr(\$4, 1, length(\$4)-1)
                o2 = substr(\$4, length(\$4), 1)
                print "L", n1, o1, n2, o2, "0M"
            } else if (\$1 == "O") {
                gsub(/ /, ",", \$3)
                print "P", \$2, \$3, "*"
            } else if (\$1 == "P" || \$1 == "L") {
                print \$0
            }
        }' > ${prefix}.gfa

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        svaha: 1.0.0
    END_VERSIONS
    """

    stub:
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    touch ${prefix}.gfa

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        svaha: 1.0.0
    END_VERSIONS
    """
}
