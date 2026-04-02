/*
 * RSEM reference preparation workflow.
 */

include { RSEM_PREPAREREFERENCE } from '../modules/rsem_preparereference.nf'
include { PUBLISH_FASTA } from '../modules/publish_fasta.nf'
include { PUBLISH_GTF } from '../modules/publish_gtf.nf'

workflow RSEM_INDEX {
    ch_fasta = Channel.fromPath(params.fasta, checkIfExists: true)
    ch_gtf   = Channel.fromPath(params.gtf,   checkIfExists: true)

    RSEM_PREPAREREFERENCE(ch_fasta, ch_gtf)
    PUBLISH_FASTA(ch_fasta)
    PUBLISH_GTF(ch_gtf)
}
