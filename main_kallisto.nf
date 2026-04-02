/*
 * Entrypoint: Build Kallisto genome index (and optionally transcriptome index).
 * Usage: nextflow run main_kallisto.nf --fasta /path/to/genome.fa [--gtf /path/to/genes.gtf] [--outdir ./results]
 */

include { KALLISTO_INDEX_WF } from './workflows/kallisto.nf'

workflow {
    if (!params.fasta) {
        exit 1, "Required parameter: --fasta (genome FASTA file)"
    }
    if (!params.outdir) {
        exit 1, "Required parameter: --outdir (output directory)"
    }
    if (!params.container) {
        exit 1, "Required parameter: --container (Kallisto container image)"
    }
    KALLISTO_INDEX_WF()
}
