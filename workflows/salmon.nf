/*
 * Salmon transcriptome index workflow.
 * Generates a transcriptome FASTA from the genome and GTF (using gffread by
 * default, or rsem-prepare-reference when params.transcriptome_source = 'rsem'),
 * then builds a Salmon index. An optional extra FASTA can be appended
 * to the transcriptome before index creation.
 */

include { MAKE_TRANSCRIPTOME } from './make_transcriptome.nf'
include { SALMON_INDEX        } from '../modules/salmon_index.nf'
include { PUBLISH_FASTA       } from '../modules/publish_fasta.nf'
include { PUBLISH_GTF         } from '../modules/publish_gtf.nf'

workflow SALMON_INDEX_WF {
    ch_genome = Channel.fromPath(params.fasta, checkIfExists: true)
    ch_gtf = Channel.fromPath(params.gtf, checkIfExists: true)
    ch_extra = Channel.fromPath(params.extra_fasta, checkIfExists: true)

    MAKE_TRANSCRIPTOME(ch_genome, ch_gtf)
    SALMON_INDEX(MAKE_TRANSCRIPTOME.out.transcriptome, ch_extra, ch_genome)
    PUBLISH_FASTA(ch_genome)
    PUBLISH_GTF(ch_gtf)
}
