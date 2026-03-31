process KALLISTO_INDEX {
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
    # Build Kallisto index
    kallisto index -i kallisto_index.idx $extra_args $transcriptome 2>&1 | tee kallisto_index.log
    # Record tool version
    kallisto version 2>&1 > versions.txt
    # Publish transcriptome FASTA (copy as-is if already gzipped, otherwise compress)
    gzip -t $transcriptome 2>/dev/null && cp $transcriptome transcriptome.fasta.gz || gzip -c $transcriptome > transcriptome.fasta.gz
    """
}
