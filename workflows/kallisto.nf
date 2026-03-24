/*
 * Kallisto transcriptome index workflow.
 */

include { KALLISTO_INDEX } from '../modules/kallisto_index.nf'
include { PUBLISH_GTF } from '../modules/publish_gtf.nf'

workflow KALLISTO_INDEX_WF {
    ch_transcriptome = Channel.fromPath(params.fasta, checkIfExists: true)

    KALLISTO_INDEX(ch_transcriptome)

    if (params.gtf) {
        ch_gtf = Channel.fromPath(params.gtf, checkIfExists: true)
        PUBLISH_GTF(ch_gtf)
    }
}
