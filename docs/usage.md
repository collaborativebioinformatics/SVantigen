# Usage

How to run the SVantigen pipeline's variation-graph construction subworkflow
(`BUILD_DRIVER_PANGENOME`).

## Requirements

- Nextflow `>= 26.04.6`
- Docker or Singularity (for the `vg` and `svaha3` containers)
- A FASTA reference and its `.fai` index
- A variant manifest TSV (see below)

## Inputs

Inputs are supplied as Nextflow command-line parameters (`--<param>`).

### `--reference` (required)

Path to the FASTA reference the graph will be built against.

### `--reference_index` (optional)

Path to the reference `.fai` index. If omitted, defaults to `<reference>.fai`
(the reference path with `.fai` appended).

### `--variants` (required)

Path to a **manifest TSV** declaring the variant files to incorporate into the
graph. The file has a header row, then one row per variant file:

| Column | Description |
| --- | --- |
| `type` | Variant category. One of `small_vcf`, `small_maf`, `sv_tsv`, `sv_vcf`, `sv_bedpe`. |
| `file` | Path to the variant file. Paths may be absolute or relative to the working directory. |

Example:

```
type	file
small_vcf	data/HG008-T_somatic_smvar.vcf.gz
sv_vcf	data/HG008-T_somatic-stvar_PASS.draftbenchmark.vcf.gz
sv_bedpe	data/HG008-T_somatic-CNV_ALL.draftbenchmark.calls.bedpe
```

Every row is optional - the graph is built from whatever variants you supply.
You can provide zero or more files of each type. A ready-to-edit example is at
[`assets/variants.tsv.example`](../assets/variants.tsv.example).

### `--outdir` (optional)

Directory to publish results into. Defaults to `./results`.

## Running

```bash
nextflow run main.nf \
    --reference GRCh38.fa \
    --variants   variants.tsv \
    --outdir    results/
```

With Singularity:

```bash
nextflow run main.nf -profile singularity \
    --reference GRCh38.fa \
    --variants   variants.tsv
```

## What it does

1. **`SVAHA3_BUILD_GRAPH`** — builds a pangenome variation graph (GFA) from the
   reference and the manifest's variant files using
   [svaha3](https://github.com/edawson/svaha).
2. **`VG_AUTOINDEX`** — converts the GFA into vg's binary GBZ format and builds
   the `vg giraffe` index set (distance, minimizer, zipcodes) using
   `vg autoindex -w giraffe`.

See [output.md](output.md) for a description of every file produced.
