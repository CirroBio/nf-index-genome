process SALMON_INDEX {
    tag "$transcriptome"

    container "${params.container}"

    input:
    path transcriptome

    output:
    path 'salmon_index', emit: index
    path "transcriptome.fasta.gz", emit: transcriptome

    script:
    def extra_args = params.salmon_extra_args ?: ""
    """
    salmon index -t $transcriptome -i salmon_index $extra_args 2>&1 | tee salmon_index.log
    salmon --version 2>&1 > versions.txt
    gzip -t $transcriptome 2>/dev/null && cp $transcriptome transcriptome.fasta.gz || gzip -c $transcriptome > transcriptome.fasta.gz
    """
}
