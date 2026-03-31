process BWA_INDEX {
    tag "$fasta"

    publishDir params.outdir, mode: 'copy', overwrite: true

    container "${params.container}"

    input:
    path fasta

    output:
    path "*"

    script:
    def extra_args = params.bwa_extra_args ?: ""
    """
    # Build BWA index with output prefix 'genome'
    bwa index -p genome $extra_args $fasta 2>&1 | tee bwa_index.log
    # Record tool version
    bwa 2>&1 | head -4 | tail -n 3 > versions.txt
    # Publish genome FASTA (copy as-is if already gzipped, otherwise compress)
    gzip -t $fasta 2>/dev/null && cp $fasta genome.fasta.gz || gzip -c $fasta > genome.fasta.gz
    """
}
