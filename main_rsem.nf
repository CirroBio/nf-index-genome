/*
 * Entrypoint: Build RSEM reference index.
 * Usage: nextflow run main_rsem.nf --fasta /path/to/genome.fa [--outdir ./results]
 */

include { RSEM_INDEX } from './workflows/rsem.nf'

workflow {
    if (!params.fasta) {
        exit 1, "Required parameter: --fasta (genome FASTA file)"
    }
    if (!params.outdir) {
        exit 1, "Required parameter: --outdir (output directory)"
    }
    if (!params.container) {
        exit 1, "Required parameter: --container (RSEM container image)"
    }
    RSEM_INDEX()
}
