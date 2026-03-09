/*
 * BWA genome index workflow using nf-core bwa/index module
 */

include { BWA_INDEX } from '../modules/bwa_index.nf'

workflow BWA_INDEX_WORKFLOW {
    ch_fasta = Channel.fromPath(params.fasta, checkIfExists: true)

    BWA_INDEX(ch_fasta)
}
