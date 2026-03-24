process PUBLISH_GTF {
    container "ubuntu:20.04"

    input:
    path gtf

    output:
    path "genome.gtf.gz"

    script:
    "gzip -t $gtf 2>/dev/null && cp $gtf genome.gtf.gz || gzip -c $gtf > genome.gtf.gz"

    stub:
    "touch genome.gtf.gz"
}
