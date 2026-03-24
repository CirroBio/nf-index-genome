process KALLISTO_INDEX {
    tag "$transcriptome"

    container "${params.container}"

    input:
    path transcriptome

    output:
    path 'kallisto_index.idx', emit: index
    path "transcriptome.fasta.gz", emit: transcriptome

    script:
    def extra_args = params.kallisto_extra_args ?: ""
    """
    kallisto index -i kallisto_index.idx $extra_args $transcriptome 2>&1 | tee kallisto_index.log
    kallisto version 2>&1 > versions.txt
    gzip -t $transcriptome 2>/dev/null && cp $transcriptome transcriptome.fasta.gz || gzip -c $transcriptome > transcriptome.fasta.gz
    """
}
