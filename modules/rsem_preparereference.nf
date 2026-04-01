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
    # Create output directory for RSEM reference files
    mkdir rsem_index
    # Build RSEM reference with output prefix 'rsem_index/genome'
    rsem-prepare-reference $extra_args $fasta rsem_index/genome 2>&1 | tee rsem_prepare_reference.log
    # Record tool version
    rsem-calculate-expression --version 2>&1 > versions.txt
    """
}
