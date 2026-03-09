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
    if (params.gtf) {
        ch_gtf = Channel.fromPath(params.gtf, checkIfExists: true)
    } else {
        CREATE_PLACEHOLDER_GTF()
        ch_gtf = CREATE_PLACEHOLDER_GTF.out
    }
    if (params.splicesites) {
        ch_ss = Channel.fromPath(params.splicesites, checkIfExists: true)
    } else {
        CREATE_PLACEHOLDER_SS()
        ch_ss = CREATE_PLACEHOLDER_SS.out
    }
    ch_fasta = Channel.fromPath(params.fasta, checkIfExists: true)
    HISAT2_BUILD(ch_fasta, ch_gtf, ch_ss)
}
