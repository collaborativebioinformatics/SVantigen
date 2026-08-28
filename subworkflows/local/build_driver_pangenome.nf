/*
 * SUBWORKFLOW: BUILD_DRIVER_PANGENOME
 * Purpose  : Build a cancer driver pangenome from a reference FASTA and a
 *            manifest of known variants, then run vg autoindex to produce a
 *            Giraffe-compatible index set.
 * Status   : implemented scaffold
 */

include { SVAHA3_BUILD_GRAPH } from '../../modules/local/svaha3/build_graph.nf'
include { VG_AUTOINDEX       } from '../../modules/local/vg/autoindex.nf'

workflow BUILD_DRIVER_PANGENOME {

    take:
    ch_reference       // channel: [ val(meta), path(reference) ]
    ch_reference_index // channel: [ val(meta), path(reference_index) ]
    ch_variants        // channel: [ val(meta), path(variants_manifest) ]

    main:
    ch_versions = Channel.empty()
    // 1. Construct Cancer SV Pangenome (GFA)
    SVAHA3_BUILD_GRAPH(
        ch_reference
            .combine(ch_reference_index)
            .combine(ch_variants)
            .map { _meta_ref, reference, _meta_idx, reference_index, _meta_var, manifest ->
                [ [id: 'driver_pangenome'], reference, reference_index, manifest ]
            }
    )
    ch_versions = ch_versions.mix(SVAHA3_BUILD_GRAPH.out.versions)

    // 2. Index the pangenome for Giraffe (GBZ, DIST, MIN)
    VG_AUTOINDEX(SVAHA3_BUILD_GRAPH.out.gfa)
    ch_versions = ch_versions.mix(VG_AUTOINDEX.out.versions)

    emit:
    index    = VG_AUTOINDEX.out.index      // channel: [ val(meta), path(gbz), path(dist), path(min) ]
    gfa      = SVAHA3_BUILD_GRAPH.out.gfa  // channel: [ val(meta), path(gfa) ]
    versions = ch_versions                 // channel: [ path(versions.yml) ]
}
