/*
 * SUBWORKFLOW: INPUT_CHECK
 * Purpose : Parse the samplesheet into typed tumor/normal channels.
 * Issue   : #19
 *
 * Expected samplesheet format:
 *     pair_id,sample,status,data_type,bam
 *
 * Emitted channels:
 *     short_tumor  // tuple(meta, path(bam))
 *     short_normal // tuple(meta, path(bam))
 *     long_tumor   // tuple(meta, path(bam))
 *     long_normal  // tuple(meta, path(bam))
 */

workflow INPUT_CHECK {

    take:
    samplesheet // path to CSV samplesheet

    main:
    samplesheet
        .splitCsv(header: true, strip: true)
        .map { row ->
            // Defensive: strip a possible UTF-8 BOM from the first header key
            def cleanRow = row.collectEntries { key, value ->
                [key.replaceAll(/^\uFEFF/, '').trim(), value]
            }

            def requiredColumns = ['pair_id', 'sample', 'status', 'data_type', 'bam']
            requiredColumns.each { col ->
                if (!cleanRow.containsKey(col) || cleanRow[col] == null || cleanRow[col].toString().trim().isEmpty()) {
                    error "Invalid samplesheet row: missing required column '${col}' in row: ${cleanRow}"
                }
            }

            if (cleanRow.status !in ['tumor', 'normal']) {
                error "Invalid samplesheet row: status must be 'tumor' or 'normal', got '${cleanRow.status}' in row: ${cleanRow}"
            }

            if (cleanRow.data_type !in ['short', 'long']) {
                error "Invalid samplesheet row: data_type must be 'short' or 'long', got '${cleanRow.data_type}' in row: ${cleanRow}"
            }

            def bam = file(cleanRow.bam)
            if (!bam.exists()) {
                error "Invalid samplesheet row: BAM file does not exist '${cleanRow.bam}' in row: ${cleanRow}"
            }

            def meta = [
                id        : cleanRow.sample,
                pair_id   : cleanRow.pair_id,
                status    : cleanRow.status,
                data_type : cleanRow.data_type
            ]

            [meta, bam]
        }
        .branch { meta, _bam ->
            short_tumor : meta.data_type == 'short' && meta.status == 'tumor'
            short_normal: meta.data_type == 'short' && meta.status == 'normal'
            long_tumor  : meta.data_type == 'long'  && meta.status == 'tumor'
            long_normal : meta.data_type == 'long'  && meta.status == 'normal'
        }
        .set { ch_samples }

    emit:
    short_tumor  = ch_samples.short_tumor
    short_normal = ch_samples.short_normal
    long_tumor   = ch_samples.long_tumor
    long_normal  = ch_samples.long_normal
}
