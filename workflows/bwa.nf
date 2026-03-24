/*
 * BWA genome index workflow using nf-core bwa/index module
 */

include { BWA_INDEX } from '../modules/bwa_index.nf'
include { PUBLISH_GTF } from '../modules/publish_gtf.nf'

workflow BWA_INDEX_WORKFLOW {
    ch_fasta = Channel.fromPath(params.fasta, checkIfExists: true)

    BWA_INDEX(ch_fasta)

    if (params.gtf) {
        ch_gtf = Channel.fromPath(params.gtf, checkIfExists: true)
        PUBLISH_GTF(ch_gtf)
    }
}
