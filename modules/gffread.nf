process GFFREAD {
    tag "$genome"

    container "${params.gffread_container}"

    input:
    path genome
    path gtf

    output:
    path "transcriptome.fasta.gz", emit: transcriptome

    script:
    """
    # Decompress genome FASTA for gffread
    gzip -t $genome 2>/dev/null && gzip -cd $genome > genome.fasta.tmp || cp $genome genome.fasta.tmp
    mv genome.fasta.tmp genome.fasta
    # Decompress GTF for gffread
    gzip -t $gtf 2>/dev/null && gzip -cd $gtf > genome.gtf.tmp || cp $gtf genome.gtf.tmp
    mv genome.gtf.tmp genome.gtf
    # Extract transcript sequences from the genome using the GTF annotation
    gffread genome.gtf -g genome.fasta -w transcriptome.fasta
    # Compress transcriptome FASTA
    gzip transcriptome.fasta
    """

    stub:
    "touch transcriptome.fasta.gz"
}
