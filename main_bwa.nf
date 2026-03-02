/*
 * Entrypoint: Build BWA genome index.
 * Usage: nextflow run main_bwa.nf --fasta /path/to/genome.fa [--outdir ./results]
 */

include { BWA_INDEX_WORKFLOW } from './workflows/bwa.nf'

workflow {
    if (!params.fasta) {
        exit 1, "Required parameter: --fasta (genome FASTA file)"
    }
    if (!params.outdir) {
        exit 1, "Required parameter: --outdir (output directory)"
    }
    if (!params.container) {
        exit 1, "Required parameter: --container (BWA container image)"
    }
    BWA_INDEX_WORKFLOW()
}
