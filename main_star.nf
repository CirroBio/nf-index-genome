/*
 * Entrypoint: Build STAR genome index (STAR 2.x).
 * Usage: nextflow run main_star.nf --fasta /path/to/genome.fa --gtf /path/to/genes.gtf [--outdir ./results]
 */

include { STAR_INDEX } from './workflows/star.nf'

workflow STAR_INDEX_MAIN {
    if (!params.fasta) {
        exit 1, "Required parameter: --fasta (genome FASTA file)"
    }
    if (!params.gtf) {
        exit 1, "Required parameter: --gtf (gene annotation GTF for splice-aware index)"
    }
    STAR_INDEX()
    STAR_INDEX.out.index
        .publishDir(params.outdir, mode: 'copy')
}
workflow { STAR_INDEX_MAIN() }
