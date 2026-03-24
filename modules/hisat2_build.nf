process HISAT2_BUILD {
    tag "${fasta}"

    container "${params.container}"

    input:
    path fasta
    path ss
    path exon
    path snp
    path haplotype

    output:
    path "*"
    path "genome.fasta.gz"

    script:
    def extra_args    = params.hisat2_extra_args ?: ""
    def ss_arg        = ss.size()        > 0 ? "--ss ${ss}"               : ""
    def exon_arg      = exon.size()      > 0 ? "--exon ${exon}"           : ""
    def snp_arg       = snp.size()       > 0 ? "--snp ${snp}"             : ""
    def haplotype_arg = haplotype.size() > 0 ? "--haplotype ${haplotype}" : ""
    """
    hisat2-build -p ${task.cpus} ${ss_arg} ${exon_arg} ${snp_arg} ${haplotype_arg} ${extra_args} ${fasta} genome 2>&1 | tee hisat2_build.log
    hisat2 --version 2>&1 > versions.txt
    gzip -t ${fasta} 2>/dev/null && cp ${fasta} genome.fasta.gz || gzip -c ${fasta} > genome.fasta.gz
    """
}
