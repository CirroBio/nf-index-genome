process PUBLISH_FASTA {
    publishDir params.outdir, mode: 'copy', pattern: "genome.fasta*"

    container "${params.samtools_container}"

    input:
    path fasta

    output:
    path "genome.fasta"
    path "genome.fasta.fai"

    script:
    """#!/bin/bash
    set -euo pipefail

    # Publish the genome FASTA uncompressed as genome.fasta.
    # Decompress any gzipped input first; otherwise copy it directly.
    if gzip -t $fasta 2>/dev/null; then
        gzip -dc $fasta > genome.fasta
    else
        cp $fasta genome.fasta
    fi

    # Index the FASTA, producing genome.fasta.fai.
    samtools faidx genome.fasta
    """

    stub:
    "touch genome.fasta genome.fasta.fai"
}
