process BOWTIE2_BUILD {
    tag "$fasta"

    publishDir params.outdir, mode: 'copy', overwrite: true

    container "${params.container}"

    input:
    path fasta

    output:
    path "*"

    script:
    def extra_args = params.bowtie2_extra_args ?: ""
    """
    # Build Bowtie2 index with output prefix 'genome'
    bowtie2-build --threads $task.cpus $extra_args $fasta genome 2>&1 | tee bowtie2_build.log
    # Record tool version
    bowtie2 --version 2>&1 > versions.txt
    # Publish genome FASTA (copy as-is if already gzipped, otherwise compress)
    gzip -t $fasta 2>/dev/null && cp $fasta genome.fasta.gz || gzip -c $fasta > genome.fasta.gz
    """
}
