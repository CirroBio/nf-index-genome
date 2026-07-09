/*
 * Cell Ranger V(D)J reference workflow.
 * Builds an immune-profiling reference with `cellranger mkvdjref` from the genome
 * FASTA and a GTF containing immunoglobulin/TCR (IG_ / TR_) gene segments.
 */

include { CELLRANGER_MKVDJREF } from '../modules/cellranger_mkvdjref.nf'
include { PUBLISH_FASTA       } from '../modules/publish_fasta.nf'
include { PUBLISH_GTF         } from '../modules/publish_gtf.nf'
include { MAKE_GFF3           } from './make_gff3.nf'

workflow CELLRANGER_VDJ_WF {
    ch_genome = Channel.fromPath(params.fasta, checkIfExists: true)
    ch_gtf = Channel.fromPath(params.gtf, checkIfExists: true)

    CELLRANGER_MKVDJREF(ch_genome, ch_gtf)
    PUBLISH_FASTA(ch_genome)
    PUBLISH_GTF(ch_gtf)
    MAKE_GFF3(ch_gtf)
}
