process GFFREAD_GFF3 {
    tag "$gtf"

    container "${params.gffread_container}"

    input:
    path gtf

    output:
    path "genome.gff3", emit: gff3

    script:
    """#!/bin/bash
    set -euo pipefail

    # Decompress the GTF if gzipped — gffread requires an uncompressed annotation file
    if gzip -t $gtf 2>/dev/null; then
        gzip -dc $gtf > genome.gtf
    else
        cp $gtf genome.gtf
    fi

    # Convert the GTF to GFF3 (gffread's default output format; -T would keep GTF).
    # Emitted uncompressed; PUBLISH_GFF3 sorts, bgzip-compresses, and tabix-indexes it.
    gffread genome.gtf -o genome.gff3
    """

    stub:
    "touch genome.gff3"
}
