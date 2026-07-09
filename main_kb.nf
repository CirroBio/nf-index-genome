/*
 * Entrypoint: Build a kallisto | bustools reference with kb-python (kb ref).
 * Usage: nextflow run main_kb.nf --fasta /path/to/genome.fa --gtf /path/to/genes.gtf [--kb_workflow nac] [--outdir ./results]
 */

include { KB_REF_WF } from './workflows/kb.nf'

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
        exit 1, "Required parameter: --container (kb-python container image)"
    }
    KB_REF_WF()
}
