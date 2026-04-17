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
    """#!/bin/bash
    set -euo pipefail

    # Decompress the GTF if gzipped and set the splice junction database option
    # STAR requires an uncompressed GTF when building a splice-aware index
    if [ -s "$gtf" ]; then
        gzip -t $gtf 2>/dev/null && gzip -cd $gtf > sjdb.gtf.tmp || cp $gtf sjdb.gtf.tmp
        mv sjdb.gtf.tmp sjdb.gtf
        SJDB_OPT="--sjdbGTFfile sjdb.gtf"
    else
        SJDB_OPT=""
    fi

    # Build the STAR genome index in the current working directory
    STAR --runMode genomeGenerate --genomeDir ./ --genomeFastaFiles $fasta \$SJDB_OPT --runThreadN $task.cpus $extra_args 2>&1 | tee star_genomegenerate.log

    # Record the STAR version used to build this index
    STAR --version 2>&1 > versions.txt

    # Copy the decompressed GTF to the output directory with the canonical filename genome.gtf
    [ -f sjdb.gtf ] && { cp sjdb.gtf genome.gtf.tmp && mv genome.gtf.tmp genome.gtf; } || true
    """
}
