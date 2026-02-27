process BISMARK_GENOMEPREPARATION {
    tag "$fasta"
    label 'process_high'

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://community-cr-prod.seqera.io/docker/registry/v2/blobs/sha256/38/38e61d14ccaed82f60c967132963eb467d0fa4bccb7a21404c49b4f377735f03/data' :
        'community.wave.seqera.io/library/bismark:0.25.1--1f50935de5d79c47' }"

    input:
    tuple val(meta), path(fasta, name: "BismarkIndex/")

    output:
    tuple val(meta), path("BismarkIndex"), emit: index
    path "versions.yml", emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    """
    bismark_genome_preparation \\
        ${args} \\
        BismarkIndex

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        bismark: \$(echo \$(bismark -v 2>&1) | sed 's/^.*Bismark Version: v//; s/Copyright.*\$//')
    END_VERSIONS
    """

    stub:
    """
    rm -f BismarkIndex/*
    mkdir -p BismarkIndex/Bisulfite_Genome/CT_conversion BismarkIndex/Bisulfite_Genome/GA_conversion
    touch BismarkIndex/Bisulfite_Genome/CT_conversion/BS_CT.{1..4}.bt2 BismarkIndex/Bisulfite_Genome/CT_conversion/BS_CT.rev.{1,2}.bt2
    touch BismarkIndex/Bisulfite_Genome/GA_conversion/BS_GA.{1..4}.bt2 BismarkIndex/Bisulfite_Genome/GA_conversion/BS_GA.rev.{1,2}.bt2
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        bismark: "0.25.1"
    END_VERSIONS
    """
}
