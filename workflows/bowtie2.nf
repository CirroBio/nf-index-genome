/*
 * Bowtie2 genome index workflow using nf-core bowtie2/build module
 */

include { BOWTIE2_BUILD } from '../modules/nf-core/modules/bowtie2/build/main.nf'

workflow BOWTIE2_INDEX {
    main:
        ch_fasta = Channel.fromPath(params.fasta, checkIfExists: true).first()
        ch_meta  = Channel.from([ [ id: 'genome' ] ])
        ch_input = ch_meta.combine(ch_fasta)

        BOWTIE2_BUILD(ch_input)

        BOWTIE2_BUILD.out.index
            .map { meta, index_dir -> [ meta, index_dir ] }
            .set { ch_index }

        ch_index
            .collect()
            .map { tuples -> tuples[0][1] }
            .set { ch_index_out }

    emit:
        index = ch_index_out
}
