/*
 * STAR genome index workflow using nf-core star/genomegenerate module
 * Supports STAR 2.x. GTF is optional but recommended for splice-aware indexing.
 */

include { STAR_GENOMEGENERATE } from '../modules/star_genomegenerate.nf'

workflow STAR_INDEX {
    ch_fasta = Channel.fromPath(params.fasta, checkIfExists: true)
    ch_gtf = Channel.fromPath(params.gtf, checkIfExists: true)

    STAR_GENOMEGENERATE(ch_fasta, ch_gtf)
}
