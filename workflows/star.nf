/*
 * STAR genome index workflow using nf-core star/genomegenerate module
 * Supports STAR 2.x. GTF is optional but recommended for splice-aware indexing.
 */

include { STAR_GENOMEGENERATE } from '../modules/nf-core/modules/star/genomegenerate/main.nf'

workflow STAR_INDEX {
    main:
        ch_fasta = Channel.fromPath(params.fasta, checkIfExists: true).first()
        ch_meta  = Channel.from([ [ id: 'genome' ] ])
        ch_gtf   = params.gtf
            ? Channel.fromPath(params.gtf, checkIfExists: true).first()
            : Channel.from(null)
        ch_meta2 = Channel.from([ [ id: 'genome' ] ])

        ch_input_fasta = ch_meta.combine(ch_fasta)
        ch_input_gtf   = params.gtf ? ch_meta2.combine(ch_gtf) : Channel.empty()

        STAR_GENOMEGENERATE(ch_input_fasta, ch_input_gtf)

        STAR_GENOMEGENERATE.out.index
            .map { meta, index_dir -> [ meta, index_dir ] }
            .set { ch_index }

        ch_index
            .collect()
            .map { tuples -> tuples[0][1] }
            .set { ch_index_out }

    emit:
        index = ch_index_out
}
