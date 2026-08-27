# METHODS

## The Goal

Personalized cancer vaccines work by finding the mutations unique to a patient's
tumor and training the immune system to recognize them — but today that search
only looks at tiny, single-letter mutations. SVantigen looks for the same kind of
vaccine targets in *large* mutations, where big chunks of DNA are deleted,
duplicated, inverted, or stitched to the wrong place.

## Why that matters

Large mutations (structural variants, or "SVs") scramble genes badly enough to
produce protein sequences the body has never seen before — exactly what a vaccine
needs to aim at. Many cancers are driven by these large rearrangements *instead
of* the small mutations, so patients whose tumors are SV-driven currently get
skipped. Widening the search widens the pool of patients who can be treated.

## How it works

We look for a patient's large mutations two ways, then combine the answers:

1. **Personal variants** — compare the patient's tumor sequencing data against a
   normal sample from the same patient, and call whatever is different. This
   finds mutations nobody has seen before, including ones private to that tumor.
2. **Recurrent variants** — build a reference that already contains the known
   cancer-driver rearrangements ("a pangenome": a reference genome that carries
   many alternative versions of each region instead of just one). Reads that
   match a known driver line up with it directly, so we detect the
   already-catalogued, drug-relevant mutations that a standard reference tends to
   hide.

Anything found only in the tumor and not in the patient's normal sample is a
candidate: either a vaccine target (neoantigen) or a mutation an existing drug
already targets.

## The pipeline

Everything runs as a [Nextflow](https://www.nextflow.io/) pipeline — a workflow
manager that chains the individual tools together, runs independent samples in
parallel, and runs each step inside its own container so the versions are pinned
and the results reproduce on someone else's machine.

**Input** is a `samplesheet.csv` listing matched tumor/normal pairs, whether each
sample is short-read or long-read, and where its BAM file lives. **Output** is a
set of filtered somatic variant calls plus a QC report, written to `--outdir`.

Between input and output the work is split into three subworkflows:

| Subworkflow | What it does |
|---|---|
| `BUILD_DRIVER_PANGENOME` | Cleans up the known driver mutations and builds them into the pangenome reference (svaha3, vg autoindex) |
| `CALL_PERSONAL_VARIANTS` | Aligns reads to the ordinary linear reference and calls both large and small mutations (minimap2, Sniffles2, DeepSomatic) |
| `CALL_RECURRENT_VARIANTS` | Aligns reads to the driver pangenome and calls variants against it (vg giraffe/pack/call), then filters to somatic-only and collects QC |

Alignment and variant calling are the slow steps, so those have optional
GPU-accelerated versions (NVIDIA Parabricks) that swap in for the CPU tools
without changing the rest of the pipeline.

We develop and benchmark against the GIAB HG008 pancreatic tumor/normal sample,
which has published truth sets for both large and small somatic mutations, so we
can measure what we find rather than guess. See
[docs/datasets.md](docs/datasets.md).

## Current status

The Nextflow scaffold, the module/subworkflow layout, and the input format are in
place. `SNIFFLES2_CALL` is implemented; the remaining modules are stubs being
filled in, and `main.nf` does not yet wire the subworkflows together.
