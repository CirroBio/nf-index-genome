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
    bwa 2>&1 | head -4 | tail -n 3 > versions.txt
    """
}
