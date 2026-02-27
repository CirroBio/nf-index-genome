/*
 * Entrypoint: Build BWA genome index.
 * Usage: nextflow run main_bwa.nf --fasta /path/to/genome.fa [--outdir ./results]
 */

include { BWA_INDEX_WORKFLOW } from './workflows/bwa.nf'

workflow {
    main:
    if (!params.fasta) {
        exit 1, "Required parameter: --fasta (genome FASTA file)"
    }
    BWA_INDEX_WORKFLOW()

    output:
        index = BWA_INDEX_WORKFLOW.out.index
}

output {
    index {
        path "${params.outdir}"
    }
}
