/*
 * Bowtie2 genome index workflow using nf-core bowtie2/build module
 */

include { BOWTIE2_BUILD } from '../modules/bowtie2_build.nf'
include { PUBLISH_GTF } from '../modules/publish_gtf.nf'

workflow BOWTIE2_INDEX {
    ch_fasta = Channel.fromPath(params.fasta, checkIfExists: true)

    BOWTIE2_BUILD(ch_fasta)

    if (params.gtf) {
        ch_gtf = Channel.fromPath(params.gtf, checkIfExists: true)
        PUBLISH_GTF(ch_gtf)
    }
}
