/*
 * SUBWORKFLOW: BUILD_DRIVER_PANGENOME
 * Purpose  : Variation graph construction.
 *           Builds a pangenome GFA from a linear reference and a manifest of
 *           known variants, then runs vg autoindex to produce a vg graph (GBZ)
 *           and the giraffe index set.
 *
 * Processes: SVAHA3_BUILD_GRAPH, VG_AUTOINDEX
 *
 * Inputs (via params):
 *   - params.reference        : FASTA reference (required)
 *   - params.reference_index  : reference .fai (optional; defaults to <reference>.fai)
 *   - params.variants         : manifest TSV (type<TAB>file, with header)
 *
 * Outputs:
 *   - gfa       : pangenome graph in GFA format (from svaha3)
 *   - gbz       : vg graph in GBZ format (from vg autoindex)
 *   - dist/min/zipcodes : giraffe index set (from vg autoindex)
 * Status   : implemented
 */

include { SVAHA3_BUILD_GRAPH } from '../../modules/local/svaha3/build_graph.nf'
include { VG_AUTOINDEX       } from '../../modules/local/vg/autoindex.nf'

workflow BUILD_DRIVER_PANGENOME {

    // take:
    // // none - reads directly from params

    if (!params.reference) error "Missing required param --reference (FASTA reference)."
    if (!params.variants)  error "Missing required param --variants (manifest TSV)."

    def meta       = [id: 'driver_pangenome']
    def reference  = file(params.reference)
    def refIdx     = file(params.reference_index ?: "${params.reference}.fai")
    def manifest   = file(params.variants)

    // main:
    SVAHA3_BUILD_GRAPH(Channel.value([meta, reference, refIdx, manifest]))
    VG_AUTOINDEX(SVAHA3_BUILD_GRAPH.out.gfa)

    // emit:
    emit:
    gfa      = SVAHA3_BUILD_GRAPH.out.gfa
    gbz      = VG_AUTOINDEX.out.gbz
    dist     = VG_AUTOINDEX.out.dist
    min      = VG_AUTOINDEX.out.min
    zipcodes = VG_AUTOINDEX.out.zipcodes
}
