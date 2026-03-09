/*
 * Bowtie2 genome index workflow using nf-core bowtie2/build module
 */

include { BOWTIE2_BUILD } from '../modules/bowtie2_build.nf'

workflow BOWTIE2_INDEX {
    ch_fasta = Channel.fromPath(params.fasta, checkIfExists: true)

    BOWTIE2_BUILD(ch_fasta)
}
