/*
 * Entrypoint: Build a 10x Genomics Cell Ranger V(D)J reference with cellranger mkvdjref.
 * Usage: nextflow run main_cellranger_vdj.nf --fasta genome.fa --gtf genes.gtf --outdir results/ --container quay.io/cumulus/cellranger:10.0.0
 *
 * Cell Ranger is proprietary 10x Genomics software; use of the container image
 * is subject to the 10x Genomics End User License Agreement. The GTF must include
 * immunoglobulin/TCR (IG_ / TR_) gene segments.
 */

include { CELLRANGER_VDJ_WF } from './workflows/cellranger_vdj.nf'

workflow {
    if (!params.fasta) {
        exit 1, "Required parameter: --fasta (genome FASTA file)"
    }
    if (!params.gtf) {
        exit 1, "Required parameter: --gtf (gene annotation GTF file)"
    }
    if (!params.outdir) {
        exit 1, "Required parameter: --outdir (output directory)"
    }
    if (!params.container) {
        exit 1, "Required parameter: --container (Cell Ranger container image)"
    }
    CELLRANGER_VDJ_WF()
}
