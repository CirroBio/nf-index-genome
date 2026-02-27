/*
 * Entrypoint: Build STAR genome index (STAR 2.x).
 * Usage: nextflow run main_star.nf --fasta /path/to/genome.fa --gtf /path/to/genes.gtf [--outdir ./results]
 */

nextflow.preview.output = true
include { STAR_INDEX } from './workflows/star.nf'

workflow {
    main:
    if (!params.fasta) {
        exit 1, "Required parameter: --fasta (genome FASTA file)"
    }
    if (!params.gtf) {
        exit 1, "Required parameter: --gtf (gene annotation GTF for splice-aware index)"
    }
    STAR_INDEX()

    publish:
        index = STAR_INDEX.out.index
}

output {
    index {
        path "${params.outdir}"
    }
}
