/*
 * Kallisto index workflow.
 * Always builds a genome index from the FASTA.
 * If a GTF is provided, also generates a transcriptome FASTA (using gffread by
 * default, or rsem-prepare-reference when params.transcriptome_source = 'rsem')
 * and builds a separate transcriptome index.
 */

include { MAKE_TRANSCRIPTOME       } from './make_transcriptome.nf'
include { KALLISTO_INDEX_GENOME      } from '../modules/kallisto_index.nf'
include { KALLISTO_INDEX_TRANSCRIPTOME } from '../modules/kallisto_index.nf'
include { PUBLISH_FASTA            } from '../modules/publish_fasta.nf'
include { PUBLISH_GTF              } from '../modules/publish_gtf.nf'

workflow KALLISTO_INDEX_WF {
    ch_genome = Channel.fromPath(params.fasta, checkIfExists: true)

    KALLISTO_INDEX_GENOME(ch_genome)
    PUBLISH_FASTA(ch_genome)

    if (params.gtf) {
        ch_gtf = Channel.fromPath(params.gtf, checkIfExists: true)
        MAKE_TRANSCRIPTOME(ch_genome, ch_gtf)
        KALLISTO_INDEX_TRANSCRIPTOME(MAKE_TRANSCRIPTOME.out.transcriptome)
        PUBLISH_GTF(ch_gtf)
    }
}
