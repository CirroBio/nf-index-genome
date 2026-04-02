process BISMARK_GENOMEPREPARATION {
    publishDir params.outdir, mode: 'copy', overwrite: true

    container "${params.container}"

    input:
    path "genome/"

    output:
    path "genome/"
    path "*"

    script:
    def extra_args = params.bismark_extra_args ?: ""
    """#!/bin/bash
set -euo pipefail

# Build the bisulfite-converted genome index inside the genome/ directory
# --genomic_composition computes base composition statistics used by Bismark during alignment
bismark_genome_preparation \\
    --${params.aligner} \\
    --parallel ${task.cpus} \\
    --genomic_composition \\
    $extra_args \\
    genome/ 2>&1 | tee bismark_genome_preparation.log

# Record the Bismark version used to build this index
bismark_genome_preparation --version 2>&1 > versions.txt
    """
}
