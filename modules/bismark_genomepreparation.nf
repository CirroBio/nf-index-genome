process BISMARK_GENOMEPREPARATION {
    tag "$fasta"

    container "${params.container}"

    input:
    path "genome/"

    output:
    path "*", emit: index
    path "genome/", emit: genome

    script:
    def extra_args = params.bismark_extra_args ?: ""
    """#!/bin/bash
set -euo pipefail

bismark_genome_preparation \
    --${params.aligner} \
    --parallel ${task.cpus} \
    --genomic_composition \
    $extra_args \
    genome/ 2>&1 | tee bismark_genome_preparation.log

bismark_genome_preparation --version 2>&1 > versions.txt
    """
}
