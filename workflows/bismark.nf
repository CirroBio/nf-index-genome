/*
 * Bismark genome preparation workflow using nf-core bismark/genomepreparation module.
 * Prepares bisulfite-converted genome indexes (uses Bowtie2 under the hood).
 */

include { BISMARK_GENOMEPREPARATION } from '../modules/bismark_genomepreparation.nf'
include { PUBLISH_FASTA } from '../modules/publish_fasta.nf'
include { PUBLISH_GTF } from '../modules/publish_gtf.nf'

workflow BISMARK_INDEX {
    ch_fasta = Channel.fromPath(params.fasta, checkIfExists: true)
    BISMARK_GENOMEPREPARATION(ch_fasta)

    ch_fasta_pub = Channel.fromPath(params.fasta, checkIfExists: true)
    PUBLISH_FASTA(ch_fasta_pub)

    if (params.gtf) {
        ch_gtf = Channel.fromPath(params.gtf, checkIfExists: true)
        PUBLISH_GTF(ch_gtf)
    }
}
