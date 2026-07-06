process PUBLISH_GFF3 {
    publishDir params.outdir, mode: 'copy', pattern: "genome.gff3.gz*"

    container "${params.bgzip_container}"

    input:
    path gff3

    output:
    path "genome.gff3.gz"
    path "genome.gff3.gz.tbi"

    script:
    """#!/bin/bash
    set -euo pipefail

    # tabix requires the records sorted by sequence name and start position.
    # Keep header lines up front, then sort the feature lines.
    (grep '^#' $gff3 || true; { grep -v '^#' $gff3 || true; } | sort -k1,1 -k4,4n) \
        | bgzip -c > genome.gff3.gz

    # Index the bgzip-compressed GFF3, producing genome.gff3.gz.tbi.
    tabix -p gff genome.gff3.gz
    """

    stub:
    "touch genome.gff3.gz genome.gff3.gz.tbi"
}
