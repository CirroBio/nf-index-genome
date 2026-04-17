process PUBLISH_FASTA {
    publishDir params.outdir, mode: 'copy', pattern: "genome.fasta.gz"

    container "ubuntu:20.04"

    input:
    path fasta

    output:
    path "genome.fasta.gz"

    script:
    """#!/bin/bash
    set -euo pipefail

    # Publish the genome FASTA with the canonical filename genome.fasta.gz
    # If the input is already gzipped, copy it directly; otherwise compress it first
    gzip -t $fasta 2>/dev/null && cp $fasta genome.fasta.gz || gzip -c $fasta > genome.fasta.gz
    """

    stub:
    "touch genome.fasta.gz"
}
