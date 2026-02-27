/*
 * Entrypoint: Build BWA genome index.
 * Usage: nextflow run main_bwa.nf --fasta /path/to/genome.fa [--outdir ./results]
 */

include { BWA_INDEX_WORKFLOW } from './workflows/bwa.nf'

workflow BWA_INDEX_MAIN {
    if (!params.fasta) {
        exit 1, "Required parameter: --fasta (genome FASTA file)"
    }
    BWA_INDEX_WORKFLOW()
    BWA_INDEX_WORKFLOW.out.index
        .publishDir(params.outdir, mode: 'copy')
}
workflow { BWA_INDEX_MAIN() }
