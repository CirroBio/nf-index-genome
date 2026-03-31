/*
 * Entrypoint: Build Salmon transcriptome index.
 * Usage: nextflow run main_salmon.nf --fasta /path/to/genome.fa --gtf /path/to/genes.gtf [--extra_fasta /path/to/extra.fa] [--outdir ./results]
 */

include { SALMON_INDEX_WF } from './workflows/salmon.nf'

workflow {
    if (!params.fasta) {
        exit 1, "Required parameter: --fasta (genome FASTA file)"
    }
    if (!params.gtf) {
        exit 1, "Required parameter: --gtf (gene annotation GTF file)"
    }
    if (!params.outdir) {
        exit 1, "Required parameter: --outdir (output directory)"
    }
    if (!params.container) {
        exit 1, "Required parameter: --container (Salmon container image)"
    }
    SALMON_INDEX_WF()
}
