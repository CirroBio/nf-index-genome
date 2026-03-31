process HISAT2_BUILD {
    tag "${fasta}"

    publishDir params.outdir, mode: 'copy', overwrite: true

    container "${params.container}"

    input:
    path fasta
    path ss
    path exon
    path snp
    path haplotype

    output:
    path "*"

    script:
    def extra_args    = params.hisat2_extra_args ?: ""
    def ss_arg        = ss.size()        > 0 ? "--ss ${ss}"               : ""
    def exon_arg      = exon.size()      > 0 ? "--exon ${exon}"           : ""
    def snp_arg       = snp.size()       > 0 ? "--snp ${snp}"             : ""
    def haplotype_arg = haplotype.size() > 0 ? "--haplotype ${haplotype}" : ""
    """
    # Build HISAT2 index with output prefix 'genome'
    hisat2-build -p ${task.cpus} ${ss_arg} ${exon_arg} ${snp_arg} ${haplotype_arg} ${extra_args} ${fasta} genome 2>&1 | tee hisat2_build.log
    # Record tool version
    hisat2 --version 2>&1 > versions.txt
    # Publish genome FASTA (copy as-is if already gzipped, otherwise compress)
    gzip -t ${fasta} 2>/dev/null && cp ${fasta} genome.fasta.gz || gzip -c ${fasta} > genome.fasta.gz
    """
}
