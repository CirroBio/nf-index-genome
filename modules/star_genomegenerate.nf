process STAR_GENOMEGENERATE {
    tag "$fasta"

    container "${params.container}"

    input:
    path fasta
    path gtf

    output:
    path "*", emit: index
    path "genome.fasta", emit: fasta
    path "genome.gtf", emit: gtf, optional: true

    script:
    def extra_args = params.star_extra_args ?: ""
    """
    if [ -s "$gtf" ]; then
      gzip -t $gtf 2>/dev/null && gzip -cd $gtf > sjdb.gtf.tmp || cp $gtf sjdb.gtf.tmp
      mv sjdb.gtf.tmp sjdb.gtf
      SJDB_OPT="--sjdbGTFfile sjdb.gtf"
    else
      SJDB_OPT=""
    fi
    STAR --runMode genomeGenerate --genomeDir ./ --genomeFastaFiles $fasta \$SJDB_OPT --runThreadN $task.cpus $extra_args 2>&1 | tee star_genomegenerate.log
    STAR --version 2>&1 > versions.txt
    gzip -t $fasta 2>/dev/null && gzip -cd $fasta > genome.fasta.tmp || cp $fasta genome.fasta.tmp
    mv genome.fasta.tmp genome.fasta
    [ -f sjdb.gtf ] && { cp sjdb.gtf genome.gtf.tmp && mv genome.gtf.tmp genome.gtf; } || true
    """
}
