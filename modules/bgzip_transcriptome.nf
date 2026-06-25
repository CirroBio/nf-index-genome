process BGZIP_TRANSCRIPTOME {
    tag "$fasta"

    container "${params.bgzip_container}"

    input:
    path fasta

    output:
    path "transcriptome.fasta.gz", emit: transcriptome

    script:
    """#!/bin/bash
    set -euo pipefail

    # bgzip (BGZF) compress the transcriptome FASTA so the published file can be indexed by htslib-based tools
    bgzip -c $fasta > transcriptome.fasta.gz
    """

    stub:
    "touch transcriptome.fasta.gz"
}
