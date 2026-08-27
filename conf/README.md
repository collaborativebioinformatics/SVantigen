# conf/

Additional Nextflow config files, split out of the root nextflow.config
as the pipeline grows. Common examples:
- base.config   - default process resource requirements (cpus/memory/time)
- test.config   - a small profile for running the pipeline on test data
- modules.config - per-process publishDir / args overrides

Wire these in from nextflow.config with `includeConfig 'conf/<file>.config'`.
