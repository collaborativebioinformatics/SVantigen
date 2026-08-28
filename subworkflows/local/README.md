# subworkflows/local/

Subworkflows chain together modules (and other subworkflows) into a
reusable unit with `take:` / `main:` / `emit:` blocks.

Three subworkflows are included:
- [build_driver_pangenome.nf](build_driver_pangenome.nf) — implemented; builds a pangenome variation graph and indexes it for `vg giraffe`. Wired into `main.nf`.
- [call_recurrent_variants.nf](call_recurrent_variants.nf) — placeholder
- [call_personal_variants.nf](call_personal_variants.nf) — scaffolded; aligns matched tumor/normal long reads to the linear reference and calls SNVs/indels (DeepSomatic) and SVs (Sniffles2). Not yet wired into `main.nf`; `SAMTOOLS_BAM2FASTQ` and `DEEPSOMATIC_CALL` are still module stubs.
Fill in the
`take`/`main`/`emit` blocks of the placeholders, and uncomment the matching
`include` line in main.nf once each one is wired up.
