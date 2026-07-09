/*
 * Cell Ranger ARC reference workflow (10x multiome: joint ATAC + gene expression).
 * Generates the mkref config from the genome FASTA, GTF and optional ATAC motifs,
 * then builds the reference with `cellranger-arc mkref`.
 */

include { CELLRANGERARC_MKREF } from '../modules/cellrangerarc_mkref.nf'
include { PUBLISH_FASTA       } from '../modules/publish_fasta.nf'
include { PUBLISH_GTF         } from '../modules/publish_gtf.nf'
include { MAKE_GFF3           } from './make_gff3.nf'

workflow CELLRANGERARC_MKREF_WF {
    ch_genome = Channel.fromPath(params.fasta, checkIfExists: true)
    ch_gtf = Channel.fromPath(params.gtf, checkIfExists: true)
    ch_motifs = Channel.fromPath(params.cellrangerarc_motifs, checkIfExists: true)

    CELLRANGERARC_MKREF(ch_genome, ch_gtf, ch_motifs)
    PUBLISH_FASTA(ch_genome)
    PUBLISH_GTF(ch_gtf)
    MAKE_GFF3(ch_gtf)
}
