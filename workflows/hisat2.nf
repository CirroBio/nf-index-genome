/*
 * HISAT2 genome index workflow using nf-core hisat2/build module.
 * GTF and splice sites are optional; use for splice-aware RNA index.
 */

include { HISAT2_BUILD } from '../modules/hisat2_build.nf'

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
    ch_fasta = Channel.fromPath(params.fasta, checkIfExists: true)
    ch_gtf = params.gtf ? Channel.fromPath(params.gtf, checkIfExists: true) : CREATE_PLACEHOLDER_GTF.out
    ch_ss = params.splicesites ? Channel.fromPath(params.splicesites, checkIfExists: true) : CREATE_PLACEHOLDER_SS.out

    HISAT2_BUILD(ch_fasta, ch_gtf, ch_ss)
}
