/*
 * Entrypoint: Build Bismark (bisulfite) genome index.
 * Usage: nextflow run main_bismark.nf --fasta /path/to/genome.fa [--outdir ./results]
 */

include { BISMARK_INDEX } from './workflows/bismark.nf'

workflow {
    if (!params.fasta) {
        exit 1, "Required parameter: --fasta (genome FASTA file)"
    }
    if (!params.outdir) {
        exit 1, "Required parameter: --outdir (output directory)"
    }
    if (!params.container) {
        exit 1, "Required parameter: --container (Bismark container image)"
    }
    BISMARK_INDEX()
}
