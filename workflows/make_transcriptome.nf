/*
 * Subworkflow: generate a transcriptome FASTA from a genome FASTA and GTF.
 *
 * Controlled by params.transcriptome_source:
 *   'gffread' (default) - use gffread to extract transcript sequences
 *   'rsem'              - use rsem-prepare-reference to extract transcript sequences
 *
 * Both paths emit a transcriptome.fasta.gz output on the 'transcriptome' channel.
 */

include { GFFREAD               } from '../modules/gffread.nf'
include { RSEM_TRANSCRIPT_FASTA } from '../modules/rsem_transcript_fasta.nf'

workflow MAKE_TRANSCRIPTOME {
    take:
    ch_fasta
    ch_gtf

    main:
    if (params.transcriptome_source == 'rsem') {
        RSEM_TRANSCRIPT_FASTA(ch_fasta, ch_gtf)
        ch_transcriptome = RSEM_TRANSCRIPT_FASTA.out.transcriptome
    } else {
        GFFREAD(ch_fasta, ch_gtf)
        ch_transcriptome = GFFREAD.out.transcriptome
    }

    emit:
    transcriptome = ch_transcriptome
}
