/*
 * Entrypoint: Build a 10x Genomics Cell Ranger ARC (multiome) reference with cellranger-arc mkref.
 * Usage: nextflow run main_cellrangerarc.nf --fasta genome.fa --gtf genes.gtf [--cellrangerarc_motifs motifs.txt] --outdir results/ --container quay.io/cumulus/cellranger-arc:2.0.2
 *
 * Cell Ranger ARC is proprietary 10x Genomics software; use of the container image
 * is subject to the 10x Genomics End User License Agreement.
 */

include { CELLRANGERARC_MKREF_WF } from './workflows/cellrangerarc.nf'

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
        exit 1, "Required parameter: --container (Cell Ranger ARC container image)"
    }
    CELLRANGERARC_MKREF_WF()
}
