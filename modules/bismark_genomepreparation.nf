process BISMARK_GENOMEPREPARATION {
    tag "$fasta"

    container "${params.container}"

    input:
    path "genome/"

    output:
    path "*"

    script:
    def extra_args = params.bismark_extra_args ?: ""
    """#!/bin/bash
set -euo pipefail

bismark_genome_preparation \
    --${params.aligner} \
    --parallel ${task.cpus} \
    --genomic_composition \
    $extra_args \
    ./

bismark_genome_preparation --version 2>&1 > versions.txt
    """
}
