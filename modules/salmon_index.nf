process SALMON_INDEX {
    tag "$transcriptome"

    container "${params.container}"

    input:
    path transcriptome

    output:
    path 'salmon_index', emit: index

    script:
    def extra_args = params.salmon_extra_args ?: ""
    """
    salmon index -t $transcriptome -i salmon_index $extra_args 2>&1 > salmon_index.log
    salmon --version 2>&1 > versions.txt
    """
}
