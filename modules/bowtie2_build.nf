process BOWTIE2_BUILD {
    tag "$fasta"

    container "${params.container}"

    input:
    path fasta

    output:
    path '*', emit: index

    script:
    def extra_args = params.bowtie2_extra_args ?: ""
    """
    bowtie2-build --threads $task.cpus $extra_args $fasta genome
    bowtie2 --version 2>&1 > versions.txt
    """
}
