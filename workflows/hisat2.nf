/*
 * HISAT2 genome index workflow using nf-core hisat2/build module.
 * Splice sites, exon, SNP, and haplotype files are all optional.
 * A GTF file can be provided instead of ss/exon files; ss and exon are then extracted automatically.
 */

include { HISAT2_BUILD } from '../modules/hisat2_build.nf'
include { PUBLISH_GTF } from '../modules/publish_gtf.nf'

// Placeholder processes — module requires path inputs even when files are not used
process CREATE_PLACEHOLDER_SS {
    container "ubuntu:20.04"
    output:
        path('empty.ss')
    script:
        'touch empty.ss'
    stub:
        'touch empty.ss'
}
process CREATE_PLACEHOLDER_EXON {
    container "ubuntu:20.04"
    output:
        path('empty.exon')
    script:
        'touch empty.exon'
    stub:
        'touch empty.exon'
}
process CREATE_PLACEHOLDER_SNP {
    container "ubuntu:20.04"
    output:
        path('empty.snp')
    script:
        'touch empty.snp'
    stub:
        'touch empty.snp'
}
process CREATE_PLACEHOLDER_HAPLOTYPE {
    container "ubuntu:20.04"
    output:
        path('empty.haplotype')
    script:
        'touch empty.haplotype'
    stub:
        'touch empty.haplotype'
}

process HISAT2_EXTRACT_SPLICE_SITES {
    container "${params.container}"
    input:
        path gtf
    output:
        path('splice_sites.ss')
    script:
        """#!/bin/bash
set -e
hisat2_extract_splice_sites.py ${gtf} > splice_sites.ss
        """
    stub:
        'touch splice_sites.ss'
}

process HISAT2_EXTRACT_EXONS {
    container "${params.container}"
    input:
        path gtf
    output:
        path('exons.exon')
    script:
        """#!/bin/bash
set -e
hisat2_extract_exons.py ${gtf} > exons.exon
        """
    stub:
        'touch exons.exon'
}

workflow HISAT2_INDEX {
    if (params.hisat2_gtf) {
        if (params.hisat2_ss || params.hisat2_exon) {
            error "Cannot specify --hisat2_ss or --hisat2_exon together with --hisat2_gtf"
        }
        ch_gtf = Channel.fromPath(params.hisat2_gtf, checkIfExists: true)
        HISAT2_EXTRACT_SPLICE_SITES(ch_gtf)
        ch_ss = HISAT2_EXTRACT_SPLICE_SITES.out
        HISAT2_EXTRACT_EXONS(ch_gtf)
        ch_exon = HISAT2_EXTRACT_EXONS.out
    } else {
        if (params.hisat2_ss) {
            ch_ss = Channel.fromPath(params.hisat2_ss, checkIfExists: true)
        } else {
            CREATE_PLACEHOLDER_SS()
            ch_ss = CREATE_PLACEHOLDER_SS.out
        }
        if (params.hisat2_exon) {
            ch_exon = Channel.fromPath(params.hisat2_exon, checkIfExists: true)
        } else {
            CREATE_PLACEHOLDER_EXON()
            ch_exon = CREATE_PLACEHOLDER_EXON.out
        }
    }
    if (params.hisat2_snp) {
        ch_snp = Channel.fromPath(params.hisat2_snp, checkIfExists: true)
    } else {
        CREATE_PLACEHOLDER_SNP()
        ch_snp = CREATE_PLACEHOLDER_SNP.out
    }
    if (params.hisat2_haplotype) {
        ch_haplotype = Channel.fromPath(params.hisat2_haplotype, checkIfExists: true)
    } else {
        CREATE_PLACEHOLDER_HAPLOTYPE()
        ch_haplotype = CREATE_PLACEHOLDER_HAPLOTYPE.out
    }
    ch_fasta = Channel.fromPath(params.fasta, checkIfExists: true)
    HISAT2_BUILD(ch_fasta, ch_ss, ch_exon, ch_snp, ch_haplotype)

    if (params.gtf) {
        ch_gtf = Channel.fromPath(params.gtf, checkIfExists: true)
        PUBLISH_GTF(ch_gtf)
    }
}
