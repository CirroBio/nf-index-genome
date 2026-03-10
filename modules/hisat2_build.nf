process HISAT2_BUILD {
    tag "${fasta}"

    container "${params.container}"

    input:
    path fasta
    path gtf
    path splicesites

    output:
    path "*"

    script:
    """
    hisat2-build -p ${task.cpus} ${ss} ${exon} ${args} ${fasta} ${fasta.baseName}
    hisat2 --version 2>&1 > versions.txt
    """
}
