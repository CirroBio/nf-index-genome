process PUBLISH_FASTA {
    publishDir params.outdir, mode: 'copy', pattern: "genome.fasta.gz"

    container "ubuntu:20.04"

    input:
    path fasta

    output:
    path "genome.fasta.gz"

    script:
    """
    # Publish genome FASTA with canonical name (copy as-is if already gzipped, otherwise compress)
    gzip -t $fasta 2>/dev/null && cp $fasta genome.fasta.gz || gzip -c $fasta > genome.fasta.gz
    """

    stub:
    "touch genome.fasta.gz"
}
