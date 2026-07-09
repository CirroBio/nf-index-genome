process SIMPLEAF_INDEX {
    tag "$fasta"

    publishDir params.outdir, mode: 'copy', overwrite: true

    container "${params.container}"

    input:
    path fasta
    path gtf

    output:
    path "*"

    script:
    def extra_args = params.simpleaf_extra_args ?: ""
    """#!/bin/bash
    set -euo pipefail

    # simpleaf builds the reference with roers, which requires uncompressed inputs
    gzip -t $fasta 2>/dev/null && gzip -cd $fasta > ref_genome.fasta || cp $fasta ref_genome.fasta
    gzip -t $gtf 2>/dev/null && gzip -cd $gtf > ref_genome.gtf || cp $gtf ref_genome.gtf

    # alevin-fry needs a writable home for its config; keep it inside the work dir
    export ALEVIN_FRY_HOME="\$PWD/af_home"
    # the piscem indexer opens many intermediate files at once
    ulimit -n 2048
    simpleaf set-paths

    # Build the spliced+intron (splici) decoy-aware reference from the genome and
    # annotation, then index it (piscem by default). Unlike a bare salmon index,
    # this emits a transcript-to-gene map (simpleaf/ref/t2g*.tsv) for alevin-fry
    # USA-mode quantification alongside the index (simpleaf/index/).
    simpleaf index \\
        --threads $task.cpus \\
        --fasta ref_genome.fasta \\
        --gtf ref_genome.gtf \\
        --output simpleaf \\
        $extra_args

    # Record the versions of the tools bundled in the simpleaf container
    {
        echo "simpleaf: \$(simpleaf --version 2>&1 | sed 's/simpleaf //')"
        echo "alevin-fry: \$(alevin-fry --version 2>&1 | sed 's/alevin-fry //')"
        echo "piscem: \$(piscem --version 2>&1 | sed 's/piscem //')"
        echo "salmon: \$(salmon --version 2>&1 | sed 's/salmon //')"
    } > versions.txt

    # Drop the decompressed inputs and alevin-fry home so they are not published;
    # the canonical FASTA/GTF are published by PUBLISH_FASTA / PUBLISH_GTF.
    rm -rf ref_genome.fasta ref_genome.gtf af_home
    """

    stub:
    """
    mkdir -p simpleaf/index simpleaf/ref
    touch simpleaf/index/piscem_idx.sshash
    touch simpleaf/ref/t2g_3col.tsv
    touch versions.txt
    """
}
