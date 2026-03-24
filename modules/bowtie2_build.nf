process BOWTIE2_BUILD {
    tag "$fasta"

    container "${params.container}"

    input:
    path fasta

    output:
    path '*', emit: index
    path "genome.fasta.gz", emit: fasta

    script:
    def extra_args = params.bowtie2_extra_args ?: ""
    """
    bowtie2-build --threads $task.cpus $extra_args $fasta genome 2>&1 | tee bowtie2_build.log
    bowtie2 --version 2>&1 > versions.txt
    gzip -t $fasta 2>/dev/null && cp $fasta genome.fasta.gz || gzip -c $fasta > genome.fasta.gz
    """
}
