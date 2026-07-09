/*
 * Cell Ranger reference workflow.
 * Builds a 10x Genomics reference package with `cellranger mkref` (which runs
 * STAR genomeGenerate internally). If params.cellranger_mkgtf_args is set, the
 * GTF is first slimmed with `cellranger mkgtf` (e.g. to protein-coding genes)
 * before mkref; otherwise mkref runs on the provided GTF directly.
 */

include { CELLRANGER_MKGTF } from '../modules/cellranger_mkref.nf'
include { CELLRANGER_MKREF } from '../modules/cellranger_mkref.nf'
include { PUBLISH_FASTA    } from '../modules/publish_fasta.nf'
include { PUBLISH_GTF      } from '../modules/publish_gtf.nf'
include { MAKE_GFF3        } from './make_gff3.nf'

workflow CELLRANGER_MKREF_WF {
    ch_genome = Channel.fromPath(params.fasta, checkIfExists: true)
    ch_gtf = Channel.fromPath(params.gtf, checkIfExists: true)

    if (params.cellranger_mkgtf_args) {
        CELLRANGER_MKGTF(ch_gtf)
        ch_ref_gtf = CELLRANGER_MKGTF.out.gtf
    } else {
        ch_ref_gtf = ch_gtf
    }

    CELLRANGER_MKREF(ch_genome, ch_ref_gtf)
    PUBLISH_FASTA(ch_genome)
    PUBLISH_GTF(ch_gtf)
    MAKE_GFF3(ch_gtf)
}
