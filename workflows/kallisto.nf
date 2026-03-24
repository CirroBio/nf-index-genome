/*
 * Kallisto transcriptome index workflow.
 */

include { KALLISTO_INDEX } from '../modules/kallisto_index.nf'

workflow KALLISTO_INDEX_WF {
    ch_transcriptome = Channel.fromPath(params.fasta, checkIfExists: true)

    KALLISTO_INDEX(ch_transcriptome)

}
