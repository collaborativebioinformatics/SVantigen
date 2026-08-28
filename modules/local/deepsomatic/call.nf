/*
 * MODULE: DEEPSOMATIC_CALL
 * Purpose : Call small somatic variants from long-read alignments using DeepSomatic
 * Status  : complete implementation
 *
 * Container : google/deepsomatic:1.7.0
 * Nf-core precursor: https://github.com/nf-core/modules/blob/master/modules/nf-core/deepsomatic/main.nf
 */

process DEEPSOMATIC_CALL {
    tag "$meta.id"
    label 'process_high'

    container "google/deepsomatic:1.7.0"

    input:
    tuple val(meta), path(bam), path(bai)
    tuple val(meta_fasta), path(fasta), path(fai)

    output:
    tuple val(meta), path("*.vcf.gz"), emit: vcf
    path "versions.yml"              , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    run_deepsomatic \\
        --reads_tumor=${bam} \\
        --ref=${fasta} \\
        --output_vcf=${prefix}.vcf.gz \\
        --sample_name_tumor=${prefix} \\
        --model_type=ONT_TUMOR_ONLY \\
        --call_variants_extra_args="allow_empty_examples=true" \\
        ${args}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        deepsomatic: 1.7.0
    END_VERSIONS
    """

    stub:
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    touch ${prefix}.vcf.gz

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        deepsomatic: 1.7.0
    END_VERSIONS
    """
}
