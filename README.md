# SVantigen: Identifying candidate neoantigens and druggable mutations in SV space

On August 20, 2026, [Moderna and Merck published a blockbuster paper with initial results from a Phase II clinical trial demonstrating the efficacy of combined Keytruda + personal neoantigen therapy](https://www.nature.com/articles/d41586-026-02612-3). This approach
used small variants unique to each patient's tumor - for over 1,000 patients - to create unique vaccines.


But small variants aren't the only variants that generate neoantigens. We know SVs exist in cancer cells and
are often protein modifiers. If we can expand neoantigen candidate prediction to SV space, we will serve more cancer patients, especially since SV drivers and SSV drivers are often mutually exclusive in many cancer types.

![SV antigen detection by a bunch of pipelines](https://github.com/collaborativebioinformatics/SVantigen/blob/main/images/SV_neoantigen_detection.drawio.png)


## Goals

## Approach

### Papers
https://www.nist.gov/programs-projects/cancer-genome-bottle

https://www.nature.com/articles/s41597-025-05438-2

https://www.biorxiv.org/content/10.64898/2026.05.01.722316v2

### Datasets

For detailed direct download links to GIAB HG008 benchmark callsets (SV/CNV and small variants), selected ONT/Illumina read sets, and recurrent driver mutation databases, see:
- [Reference & Benchmark Datasets Guide](docs/datasets.md)

---

## Quickstart

The `BUILD_DRIVER_PANGENOME` subworkflow builds a pangenome variation graph from a
linear reference and a manifest of known variants, then indexes it for
`vg giraffe` alignment.

### 1. Prepare your inputs

**Reference** (required): a FASTA file and its `.fai` index.
If you omit `--reference_index`, the pipeline assumes `<reference>.fai`.

**Variant manifest** (required): a tab-separated file with a header row, one row
per variant file you want incorporated into the graph. A copy-paste example is
at [`assets/variants.tsv.example`](assets/variants.tsv.example):

```
type	file
small_vcf	/path/to/small_somatic.vcf
small_maf	/path/to/small_somatic.maf
sv_vcf	/path/to/sv_somatic.vcf
sv_tsv	/path/to/sv_somatic.tsv
sv_bedpe	/path/to/sv_somatic.bedpe
```

`type` must be one of `small_vcf`, `small_maf`, `sv_tsv`, `sv_vcf`, `sv_bedpe`.
All rows are optional - the graph is built from whatever variants you supply
(e.g. small variants only, SVs only, or a mix).

### 2. Run the pipeline

```bash
nextflow run main.nf \
    --reference GRCh38.fa \
    --variants   variants.tsv \
    --outdir    results/
```

### 3. Collect the outputs

Everything is published under `results/pangenome/`:

| File | Description |
| --- | --- |
| `driver_pangenome.gfa` | The variation graph in GFA format (from [svaha3](https://github.com/edawson/svaha)) |
| `driver_pangenome.gbz` | The graph in vg's binary GBZ format (from `vg autoindex`) |
| `driver_pangenome.dist` | Giraffe distance index |
| `driver_pangenome.shortread.withzip.min` | Giraffe minimizer index |
| `driver_pangenome.shortread.zipcodes` | Giraffe zipcodes |

The `.gbz`, `.dist`, `.min`, and `.zipcodes` files together form the index set
required by [`vg giraffe`](https://docs.nvidia.com/clara/parabricks/tool-reference/tools/giraffe)
for short-read alignment to the pangenome.

See [docs/usage.md](docs/usage.md) for the full parameter reference and
[docs/output.md](docs/output.md) for a detailed description of every output file.

## License

## Contributing
