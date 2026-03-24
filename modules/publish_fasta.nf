process PUBLISH_FASTA {
    container "ubuntu:20.04"

    input:
    path fasta

    output:
    path "genome.fasta.gz"

    script:
    "gzip -t $fasta 2>/dev/null && cp $fasta genome.fasta.gz || gzip -c $fasta > genome.fasta.gz"

    stub:
    "touch genome.fasta.gz"
}
