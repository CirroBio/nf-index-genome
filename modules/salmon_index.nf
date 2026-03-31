process SALMON_INDEX {
    tag "$genome"

    publishDir params.outdir, mode: 'copy', overwrite: true

    container "${params.container}"

    input:
    path genome
    path gtf
    path additional_fasta

    output:
    path 'salmon_index'
    path "*"

    script:
    def extra_args = params.salmon_extra_args ?: ""
    def has_extra = additional_fasta.name != 'NO_FILE'
    def extra_setup = has_extra ? "# Stage extra FASTA with canonical name\n    cp $additional_fasta extra.fasta" : ""
    def combine_cmd = has_extra ? "# Concatenate transcriptome and extra FASTA for indexing\n    cat transcriptome.fasta extra.fasta > combined.fasta" : ""
    def salmon_input = has_extra ? "combined.fasta" : "transcriptome.fasta"
    def compress_extra = has_extra ? "# Compress extra FASTA for publishing\n    gzip -c extra.fasta > extra.fasta.gz" : ""
    """
    # Decompress genome FASTA for gffread
    gzip -t $genome 2>/dev/null && gzip -cd $genome > genome.fasta.tmp || cp $genome genome.fasta.tmp
    mv genome.fasta.tmp genome.fasta
    # Decompress GTF for gffread
    gzip -t $gtf 2>/dev/null && gzip -cd $gtf > genome.gtf.tmp || cp $gtf genome.gtf.tmp
    mv genome.gtf.tmp genome.gtf
    # Extract transcript sequences from the genome using the GTF annotation
    gffread genome.gtf -g genome.fasta -w transcriptome.fasta
    $extra_setup
    $combine_cmd
    # Build Salmon index from the transcriptome
    salmon index -t $salmon_input -i salmon_index $extra_args 2>&1 | tee salmon_index.log
    # Record tool version
    salmon --version 2>&1 > versions.txt
    # Compress transcriptome FASTA for publishing
    gzip -c transcriptome.fasta > transcriptome.fasta.gz
    $compress_extra
    """

    stub:
    def has_extra = additional_fasta.name != 'NO_FILE'
    """
    mkdir salmon_index
    touch transcriptome.fasta.gz versions.txt
    ${has_extra ? "touch extra.fasta.gz" : ""}
    """
}
