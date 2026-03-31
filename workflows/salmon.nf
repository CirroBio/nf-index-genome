/*
 * Salmon transcriptome index workflow.
 * Generates a transcriptome FASTA from the genome and GTF using gffread,
 * then builds a Salmon index. An optional extra FASTA can be appended
 * to the transcriptome before index creation.
 */

include { SALMON_INDEX } from '../modules/salmon_index.nf'
include { PUBLISH_GTF } from '../modules/publish_gtf.nf'

workflow SALMON_INDEX_WF {
    ch_genome = Channel.fromPath(params.fasta, checkIfExists: true)
    ch_gtf = Channel.fromPath(params.gtf, checkIfExists: true)
    ch_extra = params.extra_fasta
        ? Channel.fromPath(params.extra_fasta, checkIfExists: true)
        : Channel.value(file('NO_FILE'))

    SALMON_INDEX(ch_genome, ch_gtf, ch_extra)
    PUBLISH_GTF(ch_gtf)
}
