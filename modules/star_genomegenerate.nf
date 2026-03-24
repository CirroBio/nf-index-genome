process STAR_GENOMEGENERATE {
    tag "$fasta"

    container "${params.container}"

    input:
    path fasta
    path gtf

    output:
    path "*", emit: index
    path "$fasta", emit: fasta
    path "$gtf", emit: gtf

    script:
    def extra_args = params.star_extra_args ?: ""
    """
    STAR --runMode genomeGenerate --genomeDir ./ --genomeFastaFiles $fasta --sjdbGTFfile $gtf --runThreadN $task.cpus $extra_args 2>&1 | tee star_genomegenerate.log
    STAR --version 2>&1 > versions.txt
    """
}
