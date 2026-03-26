process PUBLISH_GTF {
    container "ubuntu:20.04"

    input:
    path gtf

    output:
    path "genome.gtf"

    script:
    """
    gzip -t $gtf 2>/dev/null && gzip -cd $gtf > genome.gtf.tmp || cp $gtf genome.gtf.tmp
    mv genome.gtf.tmp genome.gtf
    """

    stub:
    "touch genome.gtf"
}
