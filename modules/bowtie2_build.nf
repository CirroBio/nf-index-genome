process BOWTIE2_BUILD {
    tag "$fasta"
    label 'process_high'

    container "${params.container}"

    input:
    path fasta

    output:
    path '*', emit: index

    script:
    """
    bowtie2-build --threads $task.cpus $fasta ${fasta.baseName}
    bowtie2 --version 2>&1 > versions.txt
    """
}
