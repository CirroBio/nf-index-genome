/*
 * Entrypoint: Build HISAT2 genome index (optionally splice-aware with --gtf and --splicesites).
 * Usage: nextflow run main_hisat2.nf --fasta /path/to/genome.fa [--gtf genes.gtf] [--splicesites ss.txt] [--outdir ./results]
 */

include { HISAT2_INDEX } from './workflows/hisat2.nf'

workflow {
    if (!params.fasta) {
        exit 1, "Required parameter: --fasta (genome FASTA file)"
    }
    if (!params.outdir) {
        exit 1, "Required parameter: --outdir (output directory)"
    }
    if (!params.container) {
        exit 1, "Required parameter: --container (HISAT2 container image)"
    }
    HISAT2_INDEX()
}
