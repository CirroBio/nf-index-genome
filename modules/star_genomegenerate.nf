process STAR_GENOMEGENERATE {
    tag "$fasta"

    publishDir params.outdir, mode: 'copy', overwrite: true

    container "${params.container}"

    input:
    path fasta
    path gtf

    output:
    path "*"

    script:
    def extra_args = params.star_extra_args ?: ""
    """
    # Decompress GTF if needed and set splice junction DB option
    if [ -s "$gtf" ]; then
      gzip -t $gtf 2>/dev/null && gzip -cd $gtf > sjdb.gtf.tmp || cp $gtf sjdb.gtf.tmp
      mv sjdb.gtf.tmp sjdb.gtf
      SJDB_OPT="--sjdbGTFfile sjdb.gtf"
    else
      SJDB_OPT=""
    fi
    # Build STAR genome index in the current directory
    STAR --runMode genomeGenerate --genomeDir ./ --genomeFastaFiles $fasta \$SJDB_OPT --runThreadN $task.cpus $extra_args 2>&1 | tee star_genomegenerate.log
    # Record tool version
    STAR --version 2>&1 > versions.txt
    # Publish genome FASTA (copy as-is if already gzipped, otherwise compress)
    gzip -t $fasta 2>/dev/null && cp $fasta genome.fasta.gz || gzip -c $fasta > genome.fasta.gz
    # Publish GTF with canonical name if one was used
    [ -f sjdb.gtf ] && { cp sjdb.gtf genome.gtf.tmp && mv genome.gtf.tmp genome.gtf; } || true
    """
}
