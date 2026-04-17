process RSEM_PREPAREREFERENCE {
    tag "$fasta"

    publishDir params.outdir, mode: 'copy', overwrite: true

    container "${params.container}"

    input:
    path fasta
    path gtf

    output:
    path 'rsem_index'
    path "*"

    script:
    def extra_args = params.rsem_extra_args ?: ""
    """#!/bin/bash
    set -euo pipefail

    # Decompress the GTF if gzipped — rsem-prepare-reference requires an uncompressed annotation file
    gzip -t $gtf 2>/dev/null && gzip -cd $gtf > genome.gtf.tmp || cp $gtf genome.gtf.tmp
    mv genome.gtf.tmp genome.gtf

    # Build the RSEM reference using the GTF to define transcript boundaries
    # All output files are written under rsem_index/ with the prefix 'genome'
    mkdir rsem_index
    rsem-prepare-reference --gtf genome.gtf $extra_args $fasta rsem_index/genome 2>&1 | tee rsem_prepare_reference.log

    # Record the RSEM version used to build this reference
    rsem-calculate-expression --version 2>&1 > versions.txt
    """
}
