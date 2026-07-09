/*
 * alevin-fry (simpleaf) index workflow.
 * Builds a spliced+intron (splici) decoy-aware reference and index directly from
 * the genome FASTA and GTF using `simpleaf index` (piscem indexer by default),
 * producing the index and the transcript-to-gene map used by alevin-fry.
 * This is distinct from the bare Salmon workflow, which indexes a pre-extracted
 * transcriptome FASTA without the splici reference or t2g map.
 */

include { SIMPLEAF_INDEX } from '../modules/simpleaf_index.nf'
include { PUBLISH_FASTA  } from '../modules/publish_fasta.nf'
include { PUBLISH_GTF    } from '../modules/publish_gtf.nf'
include { MAKE_GFF3      } from './make_gff3.nf'

workflow ALEVINFRY_INDEX_WF {
    ch_genome = Channel.fromPath(params.fasta, checkIfExists: true)
    ch_gtf = Channel.fromPath(params.gtf, checkIfExists: true)

    SIMPLEAF_INDEX(ch_genome, ch_gtf)
    PUBLISH_FASTA(ch_genome)
    PUBLISH_GTF(ch_gtf)
    MAKE_GFF3(ch_gtf)
}
