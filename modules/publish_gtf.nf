process PUBLISH_GTF {
    publishDir params.outdir, mode: 'copy', pattern: "genome.gtf{,.gz,.gz.tbi}"

    container "${params.bgzip_container}"

    input:
    path gtf

    output:
    path "genome.gtf"
    path "genome.gtf.gz"
    path "genome.gtf.gz.tbi"

    script:
    """#!/bin/bash
    set -euo pipefail

    # Decompress any gzipped input first; otherwise use it directly.
    if gzip -t $gtf 2>/dev/null; then
        gzip -dc $gtf > input.gtf
    else
        cp $gtf input.gtf
    fi

    # tabix requires the records sorted by sequence name and start position.
    # Keep header lines up front, then sort the feature lines. This sorted,
    # uncompressed GTF is published alongside the bgzip/tabix-indexed copy.
    (grep '^#' input.gtf || true; { grep -v '^#' input.gtf || true; } | sort -k1,1 -k4,4n) \
        > genome.gtf

    bgzip -c genome.gtf > genome.gtf.gz

    # Index the bgzip-compressed GTF, producing genome.gtf.gz.tbi.
    tabix -p gff genome.gtf.gz
    """

    stub:
    "touch genome.gtf genome.gtf.gz genome.gtf.gz.tbi"
}
