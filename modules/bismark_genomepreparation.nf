process BISMARK_GENOMEPREPARATION {
    tag "$fasta"
    label 'process_high'

    container "${params.container}"

    input:
    path fasta

    output:
    path "*"

    script:
    """
    bismark_genome_preparation $fasta BismarkIndex

    bismark --version 2>&1 > versions.txt
    """
}
