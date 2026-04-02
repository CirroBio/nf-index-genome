process RSEM_PREPAREREFERENCE {
    tag "$fasta"

    publishDir params.outdir, mode: 'copy', overwrite: true

    container "${params.container}"

    input:
    path fasta

    output:
    path 'rsem_index'
    path "*"

    script:
    def extra_args = params.rsem_extra_args ?: ""
    """
    # Build the RSEM reference; all output files are written under rsem_index/ with the prefix 'genome'
    mkdir rsem_index
    rsem-prepare-reference $extra_args $fasta rsem_index/genome 2>&1 | tee rsem_prepare_reference.log

    # Record the RSEM version used to build this reference
    rsem-calculate-expression --version 2>&1 > versions.txt
    """
}
