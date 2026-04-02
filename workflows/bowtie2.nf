/*
 * Bowtie2 genome index workflow using nf-core bowtie2/build module
 */

include { MAKE_TRANSCRIPTOME        } from './make_transcriptome.nf'
include { BOWTIE2_BUILD             } from '../modules/bowtie2_build.nf'
include { BOWTIE2_BUILD_TRANSCRIPTOME } from '../modules/bowtie2_build.nf'
include { PUBLISH_FASTA             } from '../modules/publish_fasta.nf'
include { PUBLISH_GTF               } from '../modules/publish_gtf.nf'

workflow BOWTIE2_INDEX {
    ch_fasta = Channel.fromPath(params.fasta, checkIfExists: true)

    BOWTIE2_BUILD(ch_fasta)
    PUBLISH_FASTA(ch_fasta)

    if (params.gtf) {
        ch_gtf = Channel.fromPath(params.gtf, checkIfExists: true)
        MAKE_TRANSCRIPTOME(ch_fasta, ch_gtf)
        BOWTIE2_BUILD_TRANSCRIPTOME(MAKE_TRANSCRIPTOME.out.transcriptome)
        PUBLISH_GTF(ch_gtf)
    }
}
