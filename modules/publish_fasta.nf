process PUBLISH_FASTA {
    container "ubuntu:20.04"

    input:
    path fasta

    output:
    path "genome.fasta"

    script:
    """
    gzip -t $fasta 2>/dev/null && gzip -cd $fasta > genome.fasta.tmp || cp $fasta genome.fasta.tmp
    mv genome.fasta.tmp genome.fasta
    """

    stub:
    "touch genome.fasta"
}
