process PUBLISH_GTF {
    publishDir params.outdir, mode: 'copy', pattern: "genome.gtf"

    container "ubuntu:20.04"

    input:
    path gtf

    output:
    path "genome.gtf"

    script:
    """#!/bin/bash
    set -euo pipefail

    # Publish the GTF with the canonical filename genome.gtf
    # If the input is gzipped, decompress it first; otherwise copy it directly
    gzip -t $gtf 2>/dev/null && gzip -cd $gtf > genome.gtf.tmp || cp $gtf genome.gtf.tmp
    mv genome.gtf.tmp genome.gtf
    """

    stub:
    "touch genome.gtf"
}
