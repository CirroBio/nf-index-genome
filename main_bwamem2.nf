/*
 * Entrypoint: Build bwa-mem2 genome index.
 * Usage: nextflow run main_bwamem2.nf --fasta /path/to/genome.fa [--outdir ./results]
 */

include { BWAMEM2_INDEX_WORKFLOW } from './workflows/bwamem2.nf'

workflow {
    if (!params.fasta) {
        exit 1, "Required parameter: --fasta (genome FASTA file)"
    }
    if (!params.outdir) {
        exit 1, "Required parameter: --outdir (output directory)"
    }
    if (!params.container) {
        exit 1, "Required parameter: --container (bwa-mem2 container image)"
    }
    BWAMEM2_INDEX_WORKFLOW()
}
