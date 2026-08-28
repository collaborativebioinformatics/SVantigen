#!/usr/bin/env nextflow

include { CALL_PERSONAL_VARIANTS } from '../subworkflows/local/call_personal_variants'

workflow TEST_CALL_PERSONAL_VARIANTS {

    // 1. Mock inputs for FASTQ reads and reference FASTA
    ch_reads = Channel.of(
        [ [id: 'test_long_sample'], [ file("${projectDir}/../assets/test/tumor_long.fastq.gz", checkIfExists: true) ] ]
    )

    ch_fasta = Channel.of(
        [ [id: 'reference'], file("${projectDir}/../assets/test/reference.fasta", checkIfExists: true) ]
    )

    CALL_PERSONAL_VARIANTS( ch_reads, ch_fasta )
}

workflow {
    TEST_CALL_PERSONAL_VARIANTS()
}
