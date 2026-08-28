#!/usr/bin/env nextflow

include { CALL_RECURRENT_VARIANTS } from '../subworkflows/local/call_recurrent_variants'

workflow TEST_CALL_RECURRENT_VARIANTS {

    // 1. Mock inputs for FASTQ and BAM sample testing
    ch_reads = channel.of(
        [ [id: 'test_fastq_sample'], [ file("${projectDir}/../assets/test/tumor_short.fastq.gz", checkIfExists: true) ] ]
    )

    // 2. Mock Giraffe Index Channel [ meta, gbz, dist, min ]
    ch_giraffe_index = channel.of(
        [
            [id: 'driver_pangenome'],
            file("${projectDir}/../assets/test/reference.fasta", checkIfExists: true), // gbz
            file("${projectDir}/../assets/test/driver_svs.vcf", checkIfExists: true),  // dist
            file("${projectDir}/../assets/test/small_variants.vcf", checkIfExists: true)// min
        ]
    )

    CALL_RECURRENT_VARIANTS( ch_reads, ch_giraffe_index )
}

workflow {
    TEST_CALL_RECURRENT_VARIANTS()
}

