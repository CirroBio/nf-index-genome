process BWA_INDEX {
    tag "$fasta"

    publishDir params.outdir, mode: 'copy', overwrite: true

    container "${params.container}"

    input:
    path fasta

    output:
    path "*"

    script:
    def extra_args = params.bwa_extra_args ?: ""
    """#!/bin/bash
    set -euo pipefail

    # Build the BWA genome index; all output files share the prefix 'genome'
    bwa index -p genome $extra_args $fasta 2>&1 | tee bwa_index.log

    # Record the BWA version used to build this index
    bwa 2>&1 | head -4 | tail -n 3 > versions.txt
    """
}
