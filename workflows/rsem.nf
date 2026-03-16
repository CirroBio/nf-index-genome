/*
 * RSEM reference preparation workflow.
 */

include { RSEM_PREPAREREFERENCE } from '../modules/rsem_preparereference.nf'

workflow RSEM_INDEX {
    ch_fasta = Channel.fromPath(params.fasta, checkIfExists: true)

    RSEM_PREPAREREFERENCE(ch_fasta)
}
