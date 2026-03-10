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
    def extra_args = params.hisat2_extra_args ?: ""
    """
    hisat2-build -p ${task.cpus} --ss ${splicesites} --exon ${gtf} $extra_args ${fasta} genome
    hisat2 --version 2>&1 > versions.txt
    """
}
