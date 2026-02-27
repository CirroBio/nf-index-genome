/*
 * Entrypoint: Build STAR 2.x genome index (alias for main_star.nf).
 * Usage: nextflow run main_star2.nf --fasta /path/to/genome.fa --gtf /path/to/genes.gtf [--outdir ./results]
 */

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
