process STAR_GENOMEGENERATE {
    tag "$fasta"

    container "${params.container}"

    input:
    path fasta
    path gtf

    output:
    path "*"

    script:
    def extra_args = params.star_extra_args ?: ""
    """
    STAR --runMode genomeGenerate --genomeDir ./ --genomeFastaFiles $fasta --sjdbGTFfile $gtf --runThreadN $task.cpus $extra_args
    STAR --version 2>&1 > versions.txt
    """
}
