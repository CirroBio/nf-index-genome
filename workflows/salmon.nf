/*
 * Salmon transcriptome index workflow.
 */

include { SALMON_INDEX } from '../modules/salmon_index.nf'

workflow SALMON_INDEX_WF {
    ch_transcriptome = Channel.fromPath(params.fasta, checkIfExists: true)

    SALMON_INDEX(ch_transcriptome)
}
