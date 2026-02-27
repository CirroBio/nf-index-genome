/*
 * BWA genome index workflow using nf-core bwa/index module
 */

include { BWA_INDEX } from '../modules/nf-core/modules/bwa/index/main.nf'

workflow BWA_INDEX_WORKFLOW {
    main:
        ch_fasta = Channel.fromPath(params.fasta, checkIfExists: true).first()
        ch_meta  = Channel.from([ [ id: 'genome' ] ])
        ch_input = ch_meta.combine(ch_fasta)

        BWA_INDEX(ch_input)

        BWA_INDEX.out.index
            .map { meta, index_dir -> [ meta, index_dir ] }
            .set { ch_index }

        ch_index
            .collect()
            .map { tuples -> tuples[0][1] }
            .set { ch_index_out }

    emit:
        index = ch_index_out
}
