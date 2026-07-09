process CELLRANGER_MKGTF {
    tag "$gtf"

    publishDir params.outdir, mode: 'copy', pattern: "genes.filtered.gtf"

    container "${params.container}"

    input:
    path gtf

    output:
    path "genes.filtered.gtf", emit: gtf

    script:
    def args = params.cellranger_mkgtf_args ?: ""
    """#!/bin/bash
    set -euo pipefail

    # cellranger mkgtf requires an uncompressed GTF
    gzip -t $gtf 2>/dev/null && gzip -cd $gtf > input.gtf || cp $gtf input.gtf

    # Keep only annotation records whose attributes match the requested filters
    # (e.g. --attribute=gene_biotype:protein_coding), producing a slimmed GTF for mkref
    cellranger mkgtf input.gtf genes.filtered.gtf $args

    rm -f input.gtf
    """

    stub:
    "touch genes.filtered.gtf"
}

process CELLRANGER_MKREF {
    tag "$fasta"

    publishDir params.outdir, mode: 'copy', overwrite: true

    container "${params.container}"

    input:
    path fasta
    path gtf

    output:
    path "${params.cellranger_reference_name}", emit: reference
    path "versions.txt"                        , emit: versions

    script:
    def reference_name = params.cellranger_reference_name
    def args           = params.cellranger_mkref_args ?: ""
    // cellranger mkref runs STAR genomeGenerate internally via the martian runtime.
    // --localcores/--localmem bound the martian runtime; --nthreads is handed to STAR.
    def localmem       = task.memory ? task.memory.toGiga() : 4
    """#!/bin/bash
    set -euo pipefail

    # cellranger mkref requires uncompressed FASTA and GTF inputs. Write to
    # distinct names so the copy is safe even when the staged input is already
    # called genome.fasta / genome.gtf.
    gzip -t $fasta 2>/dev/null && gzip -cd $fasta > cr_genome.fa || cp $fasta cr_genome.fa
    gzip -t $gtf 2>/dev/null && gzip -cd $gtf > cr_genes.gtf || cp $gtf cr_genes.gtf

    # Build the 10x reference package (fasta/, genes/, star/, reference.json)
    cellranger \\
        mkref \\
        --genome=$reference_name \\
        --fasta=cr_genome.fa \\
        --genes=cr_genes.gtf \\
        --localcores=$task.cpus \\
        --localmem=$localmem \\
        --nthreads=$task.cpus \\
        $args

    # Record the Cell Ranger version used to build this reference
    cellranger --version 2>&1 > versions.txt

    # Drop the decompressed inputs so they are not published; the canonical
    # FASTA/GTF are published by PUBLISH_FASTA / PUBLISH_GTF.
    rm -f cr_genome.fa cr_genes.gtf
    """

    stub:
    """
    mkdir -p ${params.cellranger_reference_name}/star ${params.cellranger_reference_name}/fasta ${params.cellranger_reference_name}/genes
    touch ${params.cellranger_reference_name}/reference.json
    touch versions.txt
    """
}
