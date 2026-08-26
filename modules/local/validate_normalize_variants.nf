/*
 * MODULE: VALIDATE_NORMALIZE_VARIANTS
 * Purpose : Validate and normalize known driver SVs + known small somatic
 *           variants
 * Status  : placeholder - not yet implemented
 * Assigned: to be assigned
 */

process VALIDATE_NORMALIZE_VARIANTS {
    container // add container here

    input:
    path driver_sv_vcf
    path small_variant_vcf

    output:
    path "normalized_driver_svs.vcf", emit: driver_svs
    path "normalized_small_variants.vcf", emit: small_variants

    script:
    """
    # TODO: implement validation + normalization
    """
}
