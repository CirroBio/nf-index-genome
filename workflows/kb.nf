/*
 * kallisto | bustools (kb-python) reference workflow.
 * Runs `kb ref` to build a kallisto index together with the transcript-to-gene
 * map (t2g) and cDNA FASTA that BUStools uses for single-cell quantification.
 * With params.kb_workflow = 'nac' (or 'lamanno') it also emits intron references
 * for RNA-velocity. This is distinct from the bare Kallisto workflow, which builds
 * only a plain kallisto index with no t2g map.
 */

include { KB_REF        } from '../modules/kb_ref.nf'
include { PUBLISH_FASTA } from '../modules/publish_fasta.nf'
include { PUBLISH_GTF   } from '../modules/publish_gtf.nf'
include { MAKE_GFF3     } from './make_gff3.nf'

workflow KB_REF_WF {
    ch_genome = Channel.fromPath(params.fasta, checkIfExists: true)
    ch_gtf = Channel.fromPath(params.gtf, checkIfExists: true)

    KB_REF(ch_genome, ch_gtf)
    PUBLISH_FASTA(ch_genome)
    PUBLISH_GTF(ch_gtf)
    MAKE_GFF3(ch_gtf)
}
