/*
 * Entrypoint: Build Bowtie2 genome index.
 * Usage: nextflow run main_bowtie2.nf --fasta /path/to/genome.fa [--outdir ./results]
 */

include { BOWTIE2_INDEX } from './workflows/bowtie2.nf'

workflow {
    if (!params.fasta) {
        exit 1, "Required parameter: --fasta (genome FASTA file)"
    }
    if (!params.outdir) {
        exit 1, "Required parameter: --outdir (output directory)"
    }
    if (!params.container) {
        exit 1, "Required parameter: --container (Bowtie2 container image)"
    }
    BOWTIE2_INDEX()
}