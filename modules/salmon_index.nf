process SALMON_INDEX {
    tag "$transcriptome"

    publishDir params.outdir, mode: 'copy', overwrite: true

    container "${params.container}"

    input:
    path transcriptome
    path additional_fasta

    output:
    path "*"
    path "transcriptome.fasta.gz"

    script:
    def extra_args = params.salmon_extra_args ?: ""
    def has_extra = additional_fasta.size() > 2
    def extra_setup = has_extra ? "# Stage extra FASTA with canonical name\n    cp $additional_fasta extra.fasta" : ""
    def combine_cmd = has_extra ? "# Concatenate transcriptome and extra FASTA for indexing\n    cat $transcriptome extra.fasta > combined.fasta" : ""
    def salmon_input = has_extra ? "combined.fasta" : transcriptome
    """
    $extra_setup
    $combine_cmd
    # Decompress transcriptome FASTA
    gzip -t $transcriptome 2>/dev/null && gzip -cd $transcriptome > transcriptome.fasta.tmp || cp $transcriptome transcriptome.fasta.tmp
    mv transcriptome.fasta.tmp transcriptome.fasta
    # Build Salmon index from the transcriptome
    salmon index -t $salmon_input -i salmon_index $extra_args 2>&1 | tee salmon_index.log
    # Record tool version
    salmon --version 2>&1 > versions.txt
    # Publish the compressed transcriptome FASTA
    gzip transcriptome.fasta
    """

    stub:
    """
    mkdir salmon_index
    touch versions.txt
    """
}
