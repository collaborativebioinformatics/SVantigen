# subworkflows/local/

Subworkflows chain together modules (and other subworkflows) into a
reusable unit with `take:` / `main:` / `emit:` blocks.

Three placeholders are included to get started:
- [build_driver_pangenome](build_driver_pangenome/main.nf)
- [call_recurrent_variants](call_recurrent_variants/main.nf)
- [call_personal_variants](call_personal_variants/main.nf)

Fill in the
`take`/`main`/`emit` blocks, and uncomment the matching `include` line
in main.nf once each one is wired up.
