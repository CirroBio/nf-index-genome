process RSEM_PREPAREREFERENCE {
    tag "$fasta"

    container "${params.container}"

    input:
    path fasta

    output:
    path 'rsem_index', emit: index
    path "genome.fasta", emit: fasta

    script:
    def extra_args = params.rsem_extra_args ?: ""
    """
    mkdir rsem_index
    rsem-prepare-reference $extra_args $fasta rsem_index/genome 2>&1 | tee rsem_prepare_reference.log
    rsem-calculate-expression --version 2>&1 > versions.txt
    gzip -t $fasta 2>/dev/null && gzip -cd $fasta > genome.fasta || cp $fasta genome.fasta
    """
}
