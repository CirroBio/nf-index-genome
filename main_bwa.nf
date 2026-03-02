/*
 * Entrypoint: Build BWA genome index.
 * Usage: nextflow run main_bwa.nf --fasta /path/to/genome.fa [--outdir ./results]
 */

include { BWA_INDEX_WORKFLOW } from './workflows/bwa.nf'

workflow {
    if (!params.fasta) {
        exit 1, "Required parameter: --fasta (genome FASTA file)"
    }
    BWA_INDEX_WORKFLOW()
}
