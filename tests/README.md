# tests/

Pipeline tests. Suggested layout as this grows:
- Small test/dummy input data (or pointers to it)
- nf-test or pytest-workflow style test cases per module/subworkflow

Keep this separate from assets/ - assets/ is for runtime files the
pipeline itself consumes, tests/ is for verifying pipeline behavior.
