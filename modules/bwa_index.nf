process BWA_INDEX {
    tag "$fasta"

    container "${params.container}"

    input:
    path fasta

    output:
    path "*"

    script:
    def extra_args = params.bwa_extra_args ?: ""
    """
    bwa index -p genome $extra_args $fasta 2>&1 > bwa_index.log
    bwa 2>&1 | head -4 | tail -n 3 > versions.txt
    """
}
