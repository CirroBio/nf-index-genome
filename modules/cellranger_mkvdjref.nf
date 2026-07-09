process CELLRANGER_MKVDJREF {
    tag "$fasta"

    publishDir params.outdir, mode: 'copy', overwrite: true

    container "${params.container}"

    input:
    path fasta
    path gtf

    output:
    path "${params.cellranger_vdj_reference_name}", emit: reference
    path "versions.txt"                            , emit: versions

    script:
    def reference_name = params.cellranger_vdj_reference_name
    def args           = params.cellranger_mkvdjref_args ?: ""
    def localmem       = task.memory ? task.memory.toGiga() : 4
    """#!/bin/bash
    set -euo pipefail

    # cellranger mkvdjref requires uncompressed FASTA and GTF; write to distinct
    # names so the copy is safe even when the staged input is already genome.*
    gzip -t $fasta 2>/dev/null && gzip -cd $fasta > cr_genome.fa || cp $fasta cr_genome.fa
    gzip -t $gtf 2>/dev/null && gzip -cd $gtf > cr_genes.gtf || cp $gtf cr_genes.gtf

    # Build the V(D)J reference from the immunoglobulin/TCR gene segments in the
    # annotation. The GTF must contain IG_*/TR_* gene biotypes or mkvdjref errors.
    cellranger \\
        mkvdjref \\
        --genome=$reference_name \\
        --fasta=cr_genome.fa \\
        --genes=cr_genes.gtf \\
        --localcores=$task.cpus \\
        --localmem=$localmem \\
        $args

    # Record the Cell Ranger version used to build this reference
    cellranger --version 2>&1 > versions.txt

    # Drop the decompressed inputs so they are not published; the canonical
    # FASTA/GTF are published by PUBLISH_FASTA / PUBLISH_GTF.
    rm -f cr_genome.fa cr_genes.gtf
    """

    stub:
    """
    mkdir -p ${params.cellranger_vdj_reference_name}/fasta
    touch ${params.cellranger_vdj_reference_name}/fasta/regions.fa
    touch ${params.cellranger_vdj_reference_name}/reference.json
    touch versions.txt
    """
}
