process SALMON_INDEX {
    tag "$transcriptome"

    publishDir params.outdir, mode: 'copy', overwrite: true

    container "${params.container}"

    input:
    path transcriptome
    path additional_fasta
    path genome_fasta

    output:
    path "*"

    script:
    def extra_args = params.salmon_extra_args ?: ""
    def has_extra   = additional_fasta.size() > 2
    def has_genome  = genome_fasta.size()     > 2
    """#!/bin/bash
    set -euo pipefail

    # Decompress the transcriptome FASTA — Salmon requires an uncompressed input
    gzip -t $transcriptome 2>/dev/null && gzip -cd $transcriptome > transcripts.fasta.tmp || cp $transcriptome transcripts.fasta.tmp
    mv transcripts.fasta.tmp transcripts.fasta

    ${has_extra ? "# Append the additional FASTA to the transcript targets so its sequences are quantified alongside the main transcriptome\ncat transcripts.fasta $additional_fasta > combined.fasta && mv combined.fasta transcripts.fasta" : ""}

    ${has_genome ? """# Decompress the genome FASTA — required for building the decoy list and the gentrome
    gzip -t $genome_fasta 2>/dev/null && gzip -cd $genome_fasta > genome.fasta.tmp || cp $genome_fasta genome.fasta.tmp
    mv genome.fasta.tmp genome.fasta

    # Extract decoy sequence names from every FASTA header line in the genome
    # (take only the ID before the first space or tab, then strip the leading '>')
    grep '^>' genome.fasta | cut -d ' ' -f 1 | cut -d \$'\\t' -f 1 | sed 's/>//g' > decoys.txt

    # Build the gentrome by concatenating transcripts first, then genome
    # Salmon requires transcript targets to appear before genomic decoy sequences
    cat transcripts.fasta genome.fasta > gentrome.fasta

    # Build the decoy-aware Salmon index
    # Reads that map better to the genome decoy than to any transcript are discarded,
    # preventing spurious assignment of intronic/intergenic reads to transcripts
    salmon index --threads $task.cpus -t gentrome.fasta -d decoys.txt -i salmon_index $extra_args 2>&1 | tee salmon_index.log""" : """# Build a transcript-only Salmon index (no genome decoy available)
    salmon index --threads $task.cpus -t transcripts.fasta -i salmon_index $extra_args 2>&1 | tee salmon_index.log"""}

    # Record the Salmon version used to build this index
    salmon --version 2>&1 > versions.txt
    """

    stub:
    """
    mkdir salmon_index
    touch versions.txt
    """
}
