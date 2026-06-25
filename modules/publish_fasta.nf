process PUBLISH_FASTA {
    publishDir params.outdir, mode: 'copy', pattern: "genome.fasta.gz"

    container "${params.bgzip_container}"

    input:
    path fasta

    output:
    path "genome.fasta.gz"

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
    """

    stub:
    "touch genome.fasta.gz"
}
