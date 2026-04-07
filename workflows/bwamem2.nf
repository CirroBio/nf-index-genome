/*
 * bwa-mem2 genome index workflow
 */

include { BWAMEM2_INDEX } from '../modules/bwamem2_index.nf'
include { PUBLISH_FASTA } from '../modules/publish_fasta.nf'
include { PUBLISH_GTF } from '../modules/publish_gtf.nf'

workflow BWAMEM2_INDEX_WORKFLOW {
    ch_fasta = Channel.fromPath(params.fasta, checkIfExists: true)

    BWAMEM2_INDEX(ch_fasta)
    PUBLISH_FASTA(ch_fasta)

    if (params.gtf) {
        ch_gtf = Channel.fromPath(params.gtf, checkIfExists: true)
        PUBLISH_GTF(ch_gtf)
    }
}
