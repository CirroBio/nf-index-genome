process PUBLISH_FASTA {
    publishDir params.outdir, mode: 'copy', pattern: "genome.fasta.gz*"

    container "${params.samtools_container}"

    input:
    path fasta

    output:
    path "genome.fasta.gz"
    path "genome.fasta.gz.fai"
    path "genome.fasta.gz.gzi"

    script:
    """#!/bin/bash
    set -euo pipefail

    # Publish the genome FASTA as genome.fasta.gz, always bgzip (BGZF) compressed.
    # bgzip output is valid gzip, so decompress any gzipped input first, then re-compress.
    if gzip -t $fasta 2>/dev/null; then
        gzip -dc $fasta | bgzip -c > genome.fasta.gz
    else
        bgzip -c $fasta > genome.fasta.gz
    fi

    # Index the BGZF FASTA, producing genome.fasta.gz.fai and genome.fasta.gz.gzi.
    samtools faidx genome.fasta.gz
    """

    stub:
    "touch genome.fasta.gz genome.fasta.gz.fai genome.fasta.gz.gzi"
}
