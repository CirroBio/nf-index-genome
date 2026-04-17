process RSEM_TRANSCRIPT_FASTA {
    tag "$fasta"
    publishDir params.outdir, mode: 'copy', pattern: "genome.gtf"

    container "${params.rsem_container}"

    input:
    path fasta
    path gtf

    output:
    path "transcriptome.fasta.gz", emit: transcriptome

    script:
    """#!/bin/bash
    set -euo pipefail

    # Decompress the genome FASTA if gzipped — rsem-prepare-reference requires an uncompressed input
    gzip -t $fasta 2>/dev/null && gzip -cd $fasta > genome.fasta.tmp || cp $fasta genome.fasta.tmp
    mv genome.fasta.tmp genome.fasta

    # Decompress the GTF if gzipped — rsem-prepare-reference requires an uncompressed annotation file
    gzip -t $gtf 2>/dev/null && gzip -cd $gtf > genome.gtf.tmp || cp $gtf genome.gtf.tmp
    mv genome.gtf.tmp genome.gtf

    # Build the RSEM reference using the genome and GTF
    # This writes transcript sequences to rsem_ref/genome.transcripts.fa among other index files
    mkdir -p rsem_ref
    rsem-prepare-reference --gtf genome.gtf --num-threads $task.cpus genome.fasta rsem_ref/genome 2>&1 | tee rsem_transcript_fasta.log

    # Compress the transcript FASTA for consistent downstream handling
    gzip -c rsem_ref/genome.transcripts.fa > transcriptome.fasta.gz
    """

    stub:
    "touch transcriptome.fasta.gz"
}
