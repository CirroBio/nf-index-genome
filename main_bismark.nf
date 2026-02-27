/*
 * Entrypoint: Build Bismark (bisulfite) genome index.
 * Usage: nextflow run main_bismark.nf --fasta /path/to/genome.fa [--outdir ./results]
 */

include { BISMARK_INDEX } from './workflows/bismark.nf'

workflow {
    main:
    if (!params.fasta) {
        exit 1, "Required parameter: --fasta (genome FASTA file)"
    }
    BISMARK_INDEX()

    publish:
        index = BISMARK_INDEX.out.index
}

output {
    index {
        path "${params.outdir}"
    }
}
