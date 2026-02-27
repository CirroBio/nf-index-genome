/*
 * HISAT2 genome index workflow using nf-core hisat2/build module.
 * GTF and splice sites are optional; use for splice-aware RNA index.
 */

include { HISAT2_BUILD } from '../modules/nf-core/modules/hisat2/build/main.nf'

// When GTF or splice sites are not provided, we need placeholder files (module requires path inputs)
process CREATE_PLACEHOLDER_GTF {
    output:
        path('empty.gtf')
    script:
        'touch empty.gtf'
    stub:
        'touch empty.gtf'
}
process CREATE_PLACEHOLDER_SS {
    output:
        path('empty.ss')
    script:
        'touch empty.ss'
    stub:
        'touch empty.ss'
}

workflow HISAT2_INDEX {
    main:
        ch_fasta = Channel.fromPath(params.fasta, checkIfExists: true).first()
        ch_meta  = Channel.from([ [ id: 'genome' ] ])
        ch_meta2 = Channel.from([ [ id: 'genome' ] ])
        ch_meta3 = Channel.from([ [ id: 'genome' ] ])

        CREATE_PLACEHOLDER_GTF()
        CREATE_PLACEHOLDER_SS()

        ch_gtf = params.gtf
            ? Channel.fromPath(params.gtf, checkIfExists: true).first()
            : CREATE_PLACEHOLDER_GTF.out
        ch_ss = params.splicesites
            ? Channel.fromPath(params.splicesites, checkIfExists: true).first()
            : CREATE_PLACEHOLDER_SS.out

        ch_input_fasta = ch_meta.combine(ch_fasta)
        ch_input_gtf   = ch_meta2.combine(ch_gtf)
        ch_input_ss    = ch_meta3.combine(ch_ss)

        HISAT2_BUILD(ch_input_fasta, ch_input_gtf, ch_input_ss)

        HISAT2_BUILD.out.index
            .map { meta, index_dir -> [ meta, index_dir ] }
            .set { ch_index }

        ch_index
            .collect()
            .map { tuples -> tuples[0][1] }
            .set { ch_index_out }

    emit:
        index = ch_index_out
}
