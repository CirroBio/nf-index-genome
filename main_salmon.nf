/*
 * Entrypoint: Build Salmon transcriptome index.
 * Usage: nextflow run main_salmon.nf --fasta /path/to/transcriptome.fa [--outdir ./results]
 */

include { SALMON_INDEX_WF } from './workflows/salmon.nf'

workflow {
    if (!params.fasta) {
        exit 1, "Required parameter: --fasta (transcriptome FASTA file)"
    }
    if (!params.outdir) {
        exit 1, "Required parameter: --outdir (output directory)"
    }
    if (!params.container) {
        exit 1, "Required parameter: --container (Salmon container image)"
    }
    SALMON_INDEX_WF()
}
