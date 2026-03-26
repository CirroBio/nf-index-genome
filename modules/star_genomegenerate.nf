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
    def gtf_arg = gtf.size() > 0 ? "--sjdbGTFfile $gtf" : ""
    """
    STAR --runMode genomeGenerate --genomeDir ./ --genomeFastaFiles $fasta $gtf_arg --runThreadN $task.cpus $extra_args 2>&1 | tee star_genomegenerate.log
    STAR --version 2>&1 > versions.txt
    gzip -t $fasta 2>/dev/null && gzip -cd $fasta > genome.fasta.tmp || cp $fasta genome.fasta.tmp
    mv genome.fasta.tmp genome.fasta
    [ -s "$gtf" ] && { gzip -t $gtf 2>/dev/null && gzip -cd $gtf > genome.gtf.tmp || cp $gtf genome.gtf.tmp; mv genome.gtf.tmp genome.gtf; } || true
    """
}
