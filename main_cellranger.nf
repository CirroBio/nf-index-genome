/*
 * Entrypoint: Build a 10x Genomics Cell Ranger reference with cellranger mkref.
 * Usage: nextflow run main_cellranger.nf --fasta /path/to/genome.fa --gtf /path/to/genes.gtf [--outdir ./results] --container quay.io/cumulus/cellranger:10.0.0
 *
 * Cell Ranger is proprietary 10x Genomics software; use of the container image
 * is subject to the 10x Genomics End User License Agreement.
 */

include { CELLRANGER_MKREF_WF } from './workflows/cellranger.nf'

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
    CELLRANGER_MKREF_WF()
}
