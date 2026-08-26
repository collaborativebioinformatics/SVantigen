# tests/

Pipeline tests. Suggested layout as this grows:
- Small test/dummy input data (or pointers to it)
- nf-test or pytest-workflow style test cases per module/subworkflow

Keep this separate from assets/ - assets/ is for runtime files the
pipeline itself consumes, tests/ is for verifying pipeline behavior.

## Test Data Format Example

| Field | Description |
|---|---|
| `pair_id` | Identifier used to link a matched tumor and normal sample together. |
| `sample` | Unique name or identifier for the individual sample. |
| `status` | Indicates whether the sample is `tumor` or `normal`. |
| `data_type` | Indicates whether the sequencing data are `short` reads or `long` reads. |
| `bam` | Path to the BAM file containing the aligned sequencing reads for that sample. |

## Pipeline parameters

| Parameter | Description |
|---|---|
| `input` | Path to the input `samplesheet.csv`. |
| `reference` | Path to the reference genome FASTA file used for alignment and variant analysis. |
| `driver_svs` | Path to a VCF containing known driver structural variants. |
| `small_variants` | Path to a VCF containing known small variants such as SNPs and indels. |
| `outdir` | Directory where pipeline output files will be written. |