process CELLRANGERARC_MKREF {
    tag "$fasta"

    publishDir params.outdir, mode: 'copy', overwrite: true

    container "${params.container}"

    input:
    path fasta
    path gtf
    path motifs

    output:
    path "${params.cellrangerarc_reference_name}", emit: reference
    path "config"                                 , emit: config
    path "versions.txt"                           , emit: versions

    script:
    def reference_name = params.cellrangerarc_reference_name
    def args           = params.cellrangerarc_mkref_args ?: ""
    // cellranger-arc mkref is not yet wired into the martian runtime, so unlike
    // cellranger mkref it takes only --nthreads (no --localcores/--localmem).
    """#!/bin/bash
    set -euo pipefail

    # cellranger-arc mkref requires uncompressed FASTA and GTF; write to distinct
    # names so the copy is safe even when the staged input is already genome.*
    gzip -t $fasta 2>/dev/null && gzip -cd $fasta > cr_genome.fa || cp $fasta cr_genome.fa
    gzip -t $gtf 2>/dev/null && gzip -cd $gtf > cr_genes.gtf || cp $gtf cr_genes.gtf

    # Build the mkref config describing the (single) genome and annotation. Add
    # the optional ATAC TF motifs (JASPAR-format) only when a non-empty motifs
    # file was supplied. The emptiness check runs in the shell because Nextflow's
    # Groovy path.size() reports 0 for HTTP-staged inputs.
    {
        echo "{"
        echo '    organism: "${reference_name}"'
        echo '    genome: ["${reference_name}"]'
        echo '    input_fasta: ["cr_genome.fa"]'
        echo '    input_gtf: ["cr_genes.gtf"]'
        if [ "\$(wc -c < ${motifs})" -gt 2 ]; then
            echo '    input_motifs: "${motifs}"'
        fi
        echo "}"
    } > config

    # Build the joint ATAC + gene-expression reference package
    cellranger-arc \\
        mkref \\
        --config=config \\
        --nthreads=$task.cpus \\
        $args

    # Record the Cell Ranger ARC version used to build this reference
    cellranger-arc --version 2>&1 > versions.txt

    # Drop the decompressed inputs so they are not published; the canonical
    # FASTA/GTF are published by PUBLISH_FASTA / PUBLISH_GTF.
    rm -f cr_genome.fa cr_genes.gtf
    """

    stub:
    """
    mkdir -p ${params.cellrangerarc_reference_name}/star ${params.cellrangerarc_reference_name}/fasta ${params.cellrangerarc_reference_name}/genes ${params.cellrangerarc_reference_name}/regions
    touch ${params.cellrangerarc_reference_name}/reference.json
    touch config
    touch versions.txt
    """
}
