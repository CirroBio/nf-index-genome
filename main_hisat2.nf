/*
 * Entrypoint: Build HISAT2 genome index (optionally splice-aware with --gtf and --splicesites).
 * Usage: nextflow run main_hisat2.nf --fasta /path/to/genome.fa [--gtf genes.gtf] [--splicesites ss.txt] [--outdir ./results]
 */

include { HISAT2_INDEX } from './workflows/hisat2.nf'

workflow {
    main:
    if (!params.fasta) {
        exit 1, "Required parameter: --fasta (genome FASTA file)"
    }
    HISAT2_INDEX()

    output:
        index = HISAT2_INDEX.out.index
}

output {
    index {
        path "${params.outdir}"
    }
}
