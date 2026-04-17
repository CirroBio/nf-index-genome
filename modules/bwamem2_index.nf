process BWAMEM2_INDEX {
    tag "$fasta"

    publishDir params.outdir, mode: 'copy', overwrite: true

    container "${params.container}"

    input:
    path fasta

    output:
    path "*"

    script:
    def extra_args = params.bwamem2_extra_args ?: ""
    """#!/bin/bash
    set -euo pipefail

    # Build the bwa-mem2 genome index; all output files share the prefix 'genome'
    bwa-mem2 index -p genome $extra_args $fasta 2>&1 | tee bwamem2_index.log

    # Record the bwa-mem2 version used to build this index
    bwa-mem2 version 2>&1 > versions.txt
    """
}
