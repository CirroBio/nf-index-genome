process BISMARK_GENOMEPREPARATION {
    tag "$fasta"

    container "${params.container}"

    input:
    path "genome/"

    output:
    path "*"

    script:
    def slam_flag = params.slam ? "--slam" : ""
    def single_fasta_flag = params.single_fasta ? "--single_fasta" : ""
    def large_index_flag = params.large_index ? "--large-index" : ""
    """#!/bin/bash
set -euo pipefail

bismark_genome_preparation \
    --${params.aligner} \
    --parallel ${task.cpus} \
    --genomic_composition \
    $slam_flag \
    $single_fasta_flag \
    $large_index_flag \
    genome/

bismark_genome_preparation --version 2>&1 > versions.txt
    """
}
