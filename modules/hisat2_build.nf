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
    # Build the HISAT2 genome index; all output files share the prefix 'genome'
    # Splice site, exon, SNP, and haplotype arguments are included only when the
    # corresponding files are provided (non-empty placeholders are skipped automatically)
    hisat2-build -p ${task.cpus} ${ss_arg} ${exon_arg} ${snp_arg} ${haplotype_arg} ${extra_args} ${fasta} genome 2>&1 | tee hisat2_build.log

    # Record the HISAT2 version used to build this index
    hisat2 --version 2>&1 > versions.txt
    """
}
