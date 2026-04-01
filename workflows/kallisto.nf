/*
 * Kallisto transcriptome index workflow.
 * Generates a transcriptome FASTA from the genome and GTF using gffread,
 * then builds a Kallisto index.
 */

include { GFFREAD } from '../modules/gffread.nf'
include { KALLISTO_INDEX } from '../modules/kallisto_index.nf'
include { PUBLISH_FASTA } from '../modules/publish_fasta.nf'
include { PUBLISH_GTF } from '../modules/publish_gtf.nf'

workflow KALLISTO_INDEX_WF {
    ch_genome = Channel.fromPath(params.fasta, checkIfExists: true)
    ch_gtf = Channel.fromPath(params.gtf, checkIfExists: true)

    GFFREAD(ch_genome, ch_gtf)
    KALLISTO_INDEX(GFFREAD.out.transcriptome)
    PUBLISH_FASTA(ch_genome)
    PUBLISH_GTF(ch_gtf)
}
