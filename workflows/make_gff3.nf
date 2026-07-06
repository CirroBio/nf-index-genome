/*
 * Subworkflow: publish the annotation in GFF3 format alongside the GTF.
 *
 * GFFREAD_GFF3 converts the GTF to an uncompressed GFF3, which PUBLISH_GFF3
 * then sorts, bgzip-compresses, and tabix-indexes into genome.gff3.gz(.tbi).
 */

include { GFFREAD_GFF3 } from '../modules/gffread_gff3.nf'
include { PUBLISH_GFF3 } from '../modules/publish_gff3.nf'

workflow MAKE_GFF3 {
    take:
    ch_gtf

    main:
    GFFREAD_GFF3(ch_gtf)
    PUBLISH_GFF3(GFFREAD_GFF3.out.gff3)
}
