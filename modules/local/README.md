# modules/local/

Local, pipeline-specific process definitions go here — one process (or a
small handful of tightly related processes) per `.nf` file.

Convention: `TOOL_SUBCOMMAND.nf`, e.g. `vg_giraffe.nf`, containing a
single `process VG_GIRAFFE { ... }` block.

Do not put subworkflow or workflow logic here — that belongs in
`subworkflows/local/`.
