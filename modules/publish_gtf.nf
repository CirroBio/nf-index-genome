process PUBLISH_GTF {
    publishDir params.outdir, mode: 'copy', pattern: "genome.gtf.gz*"

    container "${params.bgzip_container}"

    input:
    path gtf

    output:
    path "genome.gtf.gz"
    path "genome.gtf.gz.tbi"

    script:
    """#!/bin/bash
    set -euo pipefail

    # Decompress any gzipped input first; otherwise use it directly.
    if gzip -t $gtf 2>/dev/null; then
        gzip -dc $gtf > genome.gtf
    else
        cp $gtf genome.gtf
    fi

    # tabix requires the records sorted by sequence name and start position.
    # Keep header lines up front, then sort the feature lines.
    (grep '^#' genome.gtf || true; { grep -v '^#' genome.gtf || true; } | sort -k1,1 -k4,4n) \
        | bgzip -c > genome.gtf.gz

    # Index the bgzip-compressed GTF, producing genome.gtf.gz.tbi.
    tabix -p gff genome.gtf.gz
    """

    stub:
    "touch genome.gtf.gz genome.gtf.gz.tbi"
}
