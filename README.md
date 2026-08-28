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

The **SVantigen** pipeline parses tumor/normal sample BAM or FASTQ reads via a CSV samplesheet, constructs or loads a cancer driver pangenome variation graph, and calls both recurrent pangenome variants and de novo personal variants.

### 1. Test Execution Out-of-the-Box

To run the pipeline instantly in **dry-run / stub mode** (without pulling containers or downloading data):

```bash
nextflow run main.nf -profile test -stub-run
```

To run the pipeline with full real container execution on the synthetic test dataset:

```bash
nextflow run main.nf -profile test,singularity
```

By default, `-profile test` uses `tests/samplesheet.csv` for samples and `assets/test/driver_svs.vcf` for driver variants.

---

### 2. Operational Execution Modes

#### **Mode 1: Build Driver Pangenome from Scratch (Default)**
Provide your samplesheet CSV, driver variant VCF (or manifest TSV), and reference FASTA:
```bash
nextflow run main.nf \
    --input     samplesheet.csv \
    --variants  driver_svs.vcf \
    --fasta     GRCh38.fa \
    --outdir    results/ \
    -profile    singularity
```

#### **Mode 2: Use Pre-Built GFA Pangenome Graph**
Skip graph construction by supplying a pre-built `.gfa` file (indexes graph via `VG_AUTOINDEX`):
```bash
nextflow run main.nf \
    --input      samplesheet.csv \
    --pangenome  cancer_driver.gfa \
    --fasta      GRCh38.fa \
    --outdir     results/ \
    -profile     singularity
```

#### **Mode 3: Use Pre-Built Pangenome Index (Bypass Subworkflow 1)**
Completely bypass Subworkflow 1 (`BUILD_DRIVER_PANGENOME`) by passing pre-indexed `.gbz`, `.dist`, and `.min` files:
```bash
nextflow run main.nf \
    --input            samplesheet.csv \
    --pangenome_index  "pangenome.gbz,pangenome.dist,pangenome.min" \
    --fasta            GRCh38.fa \
    --outdir           results/ \
    -profile           singularity
```

---

### 3. Samplesheet Format (`samplesheet.csv`)

Specify your samples using a CSV file with the following columns:
```csv
pair_id,sample,status,data_type,bam
pair_01,sample01,tumor,short,path/to/sample01.short.bam
pair_01,sample02,normal,short,path/to/sample02.short.bam
pair_02,sample03,tumor,long,path/to/sample03.long.bam
pair_02,sample04,normal,long,path/to/sample04.long.bam
```

- `status`: `tumor` or `normal`
- `data_type`: `short` or `long`
- `bam`: Path to BAM or FASTQ read file

---

### 4. Output Results

Everything is published under `results/`:

| Directory / File | Description |
| --- | --- |
| `results/pangenome/` | Pangenome variation graph (`.gfa`) and Giraffe index files (`.gbz`, `.dist`, `.min`) |
| `results/recurrent/` | Pangenome-aligned reads, graph genotypes, and somatic VCF callsets |
| `results/personal/` | Linear reference alignments (`.bam`), DeepSomatic VCFs, and Sniffles2 SV VCFs |
| `results/qc/` | Variant QC metrics and standalone HTML summary report |

### 4. GPU Acceleration & Parabricks Module Architecture

All GPU-accelerated process modules ([NVIDIA Clara Parabricks](https://docs.nvidia.com/clara/parabricks/index.html)) are cleanly isolated under `modules/local/parabricks/`, separated from standard CPU modules in `modules/local/`:
- `modules/local/parabricks/minimap2/align.nf` (GPU Minimap2 alignment)
- `modules/local/parabricks/deepsomatic/call.nf` (GPU DeepSomatic variant calling)
- `modules/local/parabricks/vg/giraffe.nf` (GPU Giraffe pangenome alignment)

When `--enable_gpu` is passed to Nextflow, subworkflows automatically route execution to the dedicated Parabricks GPU module suite.

See [docs/usage.md](docs/usage.md) for the full parameter reference and
[docs/output.md](docs/output.md) for a detailed description of every output file.

## License

## Contributors

- [@martings](https://github.com/martings)

## Contributing
