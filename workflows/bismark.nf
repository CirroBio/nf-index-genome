/*
 * Bismark genome preparation workflow using nf-core bismark/genomepreparation module.
 * Prepares bisulfite-converted genome indexes (uses Bowtie2 under the hood).
 */

include { BISMARK_GENOMEPREPARATION } from '../modules/nf-core/modules/bismark/genomepreparation/main.nf'

workflow BISMARK_INDEX {
    main:
        // Bismark expects genome fasta in a directory; stage fasta into a dir for the module
        ch_fasta = Channel.fromPath(params.fasta, checkIfExists: true).first()
        ch_meta  = Channel.from([ [ id: 'genome' ] ])
        ch_input = ch_meta.combine(ch_fasta)

        BISMARK_GENOMEPREPARATION(ch_input)

        BISMARK_GENOMEPREPARATION.out.index
            .map { meta, index_dir -> [ meta, index_dir ] }
            .set { ch_index }

        ch_index
            .collect()
            .map { tuples -> tuples[0][1] }
            .set { ch_index_out }

    emit:
        index = ch_index_out
}
