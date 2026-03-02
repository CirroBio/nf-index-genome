process BWA_INDEX {
    tag "$fasta"

    container "${params.container}"

    input:
    path fasta

    output:
    path "*"

    script:
    """
    bwa index -p ${fasta.baseName} $fasta
    bwa --version 2>&1 > versions.txt
    """
}
