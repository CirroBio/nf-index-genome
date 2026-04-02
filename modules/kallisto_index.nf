process KALLISTO_INDEX_GENOME {
    tag "$fasta"

    publishDir params.outdir, mode: 'copy', overwrite: true

    container "${params.container}"

    input:
    path fasta

    output:
    path "*"

    script:
    def extra_args = params.kallisto_extra_args ?: ""
    """
    # Build the Kallisto genome index and write it to genome.idx
    kallisto index -i genome.idx $extra_args $fasta 2>&1 | tee kallisto_index_genome.log

    # Record the Kallisto version used to build this index
    kallisto version 2>&1 > versions.txt
    """
}

process KALLISTO_INDEX_TRANSCRIPTOME {
    tag "$transcriptome"

    publishDir params.outdir, mode: 'copy', overwrite: true

    container "${params.container}"

    input:
    path transcriptome

    output:
    path "*"

    script:
    def extra_args = params.kallisto_extra_args ?: ""
    """
    # Build the Kallisto transcriptome index and write it to transcriptome.idx
    kallisto index -i transcriptome.idx $extra_args $transcriptome 2>&1 | tee kallisto_index_transcriptome.log

    # Record the Kallisto version used to build this index
    kallisto version 2>&1 > versions.txt

    # Publish the transcriptome FASTA alongside the index with a canonical filename
    # Copy as-is if already gzipped, otherwise compress it first
    gzip -t $transcriptome 2>/dev/null && cp $transcriptome transcriptome.fasta.gz || gzip -c $transcriptome > transcriptome.fasta.gz
    """
}
