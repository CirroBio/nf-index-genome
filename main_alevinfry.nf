/*
 * Entrypoint: Build an alevin-fry reference index with simpleaf.
 * Usage: nextflow run main_alevinfry.nf --fasta /path/to/genome.fa --gtf /path/to/genes.gtf [--outdir ./results]
 */

include { ALEVINFRY_INDEX_WF } from './workflows/alevinfry.nf'

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
        exit 1, "Required parameter: --container (simpleaf container image)"
    }
    ALEVINFRY_INDEX_WF()
}
