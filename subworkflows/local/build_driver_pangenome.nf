/*
 * SUBWORKFLOW: BUILD_DRIVER_PANGENOME
 * Purpose  : Construct and index a cancer driver + recurrent neoantigen pangenome graph
 * Status   : complete implementation
 *
 * Processes: VALIDATE_NORMALIZE_VARIANTS, SVAHA3_BUILD_GRAPH, VG_AUTOINDEX
 *
 * Inputs:
 *  - ch_vcf   : [ val(meta), path(vcf) ] - Input driver SV VCF file
 *  - ch_fasta : [ val(meta_fasta), path(fasta) ] - Reference genome FASTA
 *
 * Outputs:
 *  - gfa      : [ val(meta), path(gfa) ] - Pangenome graph in GFA format
 *  - index    : [ val(meta), path(gbz), path(dist), path(min) ] - Giraffe index set
 *  - versions : [ path(versions.yml) ] - Software version reporting
 *
 * Notes:
 *  - Validates and normalizes driver SV VCF records with bcftools norm
 *  - Builds pangenome graph via vg construct (svaha3)
 *  - Indexes graph into GBZ, DIST, and MIN files using vg autoindex --workflow giraffe
 */

include { VALIDATE_NORMALIZE_VARIANTS } from '../../modules/local/validate_normalize_variants.nf'   
include { SVAHA3_BUILD_GRAPH          } from '../../modules/local/svaha3/build_graph.nf' 
include { VG_AUTOINDEX                } from '../../modules/local/vg/autoindex.nf'

workflow BUILD_DRIVER_PANGENOME {

    take:
    ch_vcf    // channel: [ val(meta), path(vcf) ]
    ch_fasta  // channel: [ val(meta_fasta), path(fasta) ]

    main:
    ch_versions = Channel.empty()

    // 1. Validate and normalize driver variants VCF
    VALIDATE_NORMALIZE_VARIANTS ( ch_vcf )
    ch_versions = ch_versions.mix(VALIDATE_NORMALIZE_VARIANTS.out.versions)

    // 2. Construct Cancer SV Pangenome (GFA)
    SVAHA3_BUILD_GRAPH ( VALIDATE_NORMALIZE_VARIANTS.out.vcf, ch_fasta )
    ch_versions = ch_versions.mix(SVAHA3_BUILD_GRAPH.out.versions)

    // 3. Index the pangenome for Giraffe (GBZ, DIST, MIN)
    VG_AUTOINDEX ( SVAHA3_BUILD_GRAPH.out.gfa )
    ch_versions = ch_versions.mix(VG_AUTOINDEX.out.versions)

    emit:
    gfa      = SVAHA3_BUILD_GRAPH.out.gfa  // channel: [ val(meta), path(gfa) ]
    index    = VG_AUTOINDEX.out.index      // channel: [ val(meta), path(gbz), path(dist), path(min) ]
    versions = ch_versions                 // channel: [ path(versions.yml) ]
}
