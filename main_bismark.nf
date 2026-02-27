/*
 * Entrypoint: Build Bismark (bisulfite) genome index.
 * Usage: nextflow run main_bismark.nf --fasta /path/to/genome.fa [--outdir ./results]
 */

include { BISMARK_INDEX } from './workflows/bismark.nf'

workflow BISMARK_INDEX_MAIN {
    if (!params.fasta) {
        exit 1, "Required parameter: --fasta (genome FASTA file)"
    }
    BISMARK_INDEX()
    BISMARK_INDEX.out.index
        .publishDir(params.outdir, mode: 'copy')
}
workflow { BISMARK_INDEX_MAIN() }
