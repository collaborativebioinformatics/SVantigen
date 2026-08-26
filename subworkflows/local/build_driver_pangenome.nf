/*
 * SUBWORKFLOW: BUILD_DRIVER_PANGENOME
 * Purpose  : Creates a cancer driver pangenome to be used for calling recurrent variants
 * Status   : placeholder, not yet implemented
 * Assigned : to be assigned
 */

include { VALIDATE_NORMALIZE_VARIANTS } from '../../modules/local/validate_normalize_variants.nf'   
include { SVAHA3_BUILD_GRAPH          } from '../../modules/local/svaha3/build_graph.nf' 
include { VG_AUTOINDEX                } from '../../modules/local/vg/autoindex.nf'

workflow BUILD_DRIVER_PANGENOME {

    take:
    reference_fasta
    driver_sv_vcf
    small_variant_vcf

    main:

    VALIDATE_NORMALIZE_VARIANTS(
        driver_sv_vcf,
        small_variant_vcf
    )

    SVAHA3_BUILD_GRAPH(
        reference_fasta,
        VALIDATE_NORMALIZE_VARIANTS.out
    )

    VG_AUTOINDEX(
        SVAHA3_BUILD_GRAPH.out
    )

    // emit:
    // // ch_output  // e.g. output channel
}
