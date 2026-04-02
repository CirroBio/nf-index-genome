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
    # Build the Bowtie2 genome index; all output files share the prefix 'genome'
    bowtie2-build --threads $task.cpus $extra_args $fasta genome 2>&1 | tee bowtie2_build_genome.log

    # Record the Bowtie2 version used to build this index
    bowtie2 --version 2>&1 > versions.txt
    """
}

process BOWTIE2_BUILD_TRANSCRIPTOME {
    tag "$transcriptome"

    publishDir params.outdir, mode: 'copy', overwrite: true

    container "${params.container}"

    input:
    path transcriptome

    output:
    path "*"

    script:
    def extra_args = params.bowtie2_extra_args ?: ""
    """
    # Build the Bowtie2 transcriptome index; all output files share the prefix 'transcriptome'
    bowtie2-build --threads $task.cpus $extra_args $transcriptome transcriptome 2>&1 | tee bowtie2_build_transcriptome.log

    # Record the Bowtie2 version used to build this index
    bowtie2 --version 2>&1 > versions.txt
    """
}
