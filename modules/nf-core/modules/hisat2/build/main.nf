process HISAT2_BUILD {
    tag "${fasta}"
    label 'process_high'
    label 'process_high_memory'

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://community-cr-prod.seqera.io/docker/registry/v2/blobs/sha256/d2/d2ec9b73c6b92e99334c6500b1b622edaac316315ac1708f0b425df3131d0a83/data' :
        'community.wave.seqera.io/library/hisat2_samtools:6be64e12472a7b75' }"

    input:
    tuple val(meta), path(fasta)
    tuple val(meta2), path(gtf)
    tuple val(meta3), path(splicesites)

    output:
    tuple val(meta), path("hisat2"), emit: index
    tuple val("${task.process}"), val('hisat2'), eval("hisat2 --version | sed -n 's/.*version \\([^ ]*\\).*/\\1/p'"), emit: versions_hisat2, topic: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def avail_mem = task.memory ? task.memory.toGiga() : 0
    def hisat2_build_memory = params.hisat2_build_memory ? (params.hisat2_build_memory as MemoryUnit).toGiga() : 0
    def extract_exons = (gtf && avail_mem >= hisat2_build_memory) ? "hisat2_extract_exons.py ${gtf} > ${gtf.baseName}.exons.txt" : ""
    def ss = (splicesites && avail_mem >= hisat2_build_memory) ? "--ss ${splicesites}" : ""
    def exon = (gtf && avail_mem >= hisat2_build_memory) ? "--exon ${gtf.baseName}.exons.txt" : ""
    """
    mkdir hisat2
    ${extract_exons}
    hisat2-build -p ${task.cpus} ${ss} ${exon} ${args} ${fasta} hisat2/${fasta.baseName}
    """

    stub:
    """
    mkdir hisat2
    touch hisat2/${fasta.baseName}.{1..8}.ht2
    """
}
