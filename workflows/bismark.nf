/*
 * Bismark genome preparation workflow using nf-core bismark/genomepreparation module.
 * Prepares bisulfite-converted genome indexes (uses Bowtie2 under the hood).
 */

include { BISMARK_GENOMEPREPARATION } from '../modules/bismark_genomepreparation.nf'

workflow BISMARK_INDEX {
    ch_fasta = Channel.fromPath(params.fasta, checkIfExists: true)

    BISMARK_GENOMEPREPARATION(ch_fasta)
}
