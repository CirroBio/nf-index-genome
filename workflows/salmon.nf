/*
 * Salmon transcriptome index workflow.
 */

include { SALMON_INDEX } from '../modules/salmon_index.nf'
include { PUBLISH_GTF } from '../modules/publish_gtf.nf'

workflow SALMON_INDEX_WF {
    ch_transcriptome = Channel.fromPath(params.fasta, checkIfExists: true)

    SALMON_INDEX(ch_transcriptome)

    if (params.gtf) {
        ch_gtf = Channel.fromPath(params.gtf, checkIfExists: true)
        PUBLISH_GTF(ch_gtf)
    }
}
