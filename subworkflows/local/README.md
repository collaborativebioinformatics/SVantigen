# subworkflows/local/

Subworkflows chain together modules (and other subworkflows) into a
reusable unit with `take:` / `main:` / `emit:` blocks.

Three subworkflows are included:
- [build_driver_pangenome.nf](build_driver_pangenome.nf) — builds a pangenome variation graph and indexes it for `vg giraffe`.
- [call_recurrent_variants.nf](call_recurrent_variants.nf) — aligns reads to pangenome graph and calls recurrent variants.
- [call_personal_variants.nf](call_personal_variants.nf) — aligns reads to linear reference and calls personal variants.
