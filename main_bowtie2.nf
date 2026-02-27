/*
 * Entrypoint: Build Bowtie2 genome index.
 * Usage: nextflow run main_bowtie2.nf --fasta /path/to/genome.fa [--outdir ./results]
 */

include { BOWTIE2_INDEX } from './workflows/bowtie2.nf'

workflow {
    main:
    if (!params.fasta) {
        exit 1, "Required parameter: --fasta (genome FASTA file)"
    }
    BOWTIE2_INDEX()

    output:
        index = BOWTIE2_INDEX.out.index
}

output {
    index {
        path "${params.outdir}"
    }
}