process STAR_GENOMEGENERATE {
    tag "$fasta"

    container "${params.container}"

    input:
    path fasta
    path gtf

    output:
    path "*"

    script:
    """
    STAR --runMode genomeGenerate --genomeDir ${fasta.baseName} --genomeFastaFiles $fasta --sjdbGTFfile $gtf --runThreadN $task.cpus
    STAR --version 2>&1 > versions.txt
    """
}
