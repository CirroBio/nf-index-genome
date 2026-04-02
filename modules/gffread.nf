process GFFREAD {
    tag "$genome"
    publishDir params.outdir, mode: 'copy', pattern: "genome.gtf"

    container "${params.gffread_container}"

    input:
    path genome
    path gtf

    output:
    path "transcriptome.fasta.gz", emit: transcriptome

    script:
    """
    # Decompress the genome FASTA if gzipped — gffread requires an uncompressed input
    gzip -t $genome 2>/dev/null && gzip -cd $genome > genome.fasta.tmp || cp $genome genome.fasta.tmp
    mv genome.fasta.tmp genome.fasta

    # Decompress the GTF if gzipped — gffread requires an uncompressed annotation file
    gzip -t $gtf 2>/dev/null && gzip -cd $gtf > genome.gtf.tmp || cp $gtf genome.gtf.tmp
    mv genome.gtf.tmp genome.gtf

    # Extract transcript sequences from the genome using the coordinates in the GTF
    # The -w flag writes spliced exon sequences (one entry per transcript)
    gffread genome.gtf -g genome.fasta -w transcriptome.fasta

    # Compress the transcript FASTA for consistent downstream handling
    gzip transcriptome.fasta
    """

    stub:
    "touch transcriptome.fasta.gz"
}
