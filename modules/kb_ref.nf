process KB_REF {
    tag "$fasta"

    publishDir params.outdir, mode: 'copy', overwrite: true

    container "${params.container}"

    input:
    path fasta
    path gtf

    output:
    path "*"

    script:
    def workflow_mode = params.kb_workflow ?: 'standard'
    def extra_args = params.kb_extra_args ?: ""
    if (workflow_mode == 'standard') {
        """#!/bin/bash
        set -euo pipefail

        # Build the kallisto index plus the transcript-to-gene map (t2g) and cDNA
        # FASTA that BUStools needs for single-cell quantification. kb-python reads
        # gzipped FASTA/GTF directly, so no decompression is required.
        kb ref \\
            -i index.idx \\
            -g t2g.txt \\
            -f1 cdna.fa \\
            --workflow standard \\
            $extra_args \\
            $fasta $gtf 2>&1 | tee kb_ref.log

        # Record the kb-python / kallisto / bustools versions used to build this
        # reference. kb-python has no --version flag and `kb info` exits non-zero
        # even on success, so tolerate the exit code and keep its first three
        # lines (kb_python / kallisto / bustools versions).
        kb info > kb_info.txt 2>&1 || true
        head -n 3 kb_info.txt > versions.txt
        rm -f kb_info.txt
        """
    } else {
        """#!/bin/bash
        set -euo pipefail

        # RNA-velocity reference: additionally emit the intron (nascent) FASTA and
        # the cDNA/intron capture lists (t2c) required by the '$workflow_mode' workflow.
        kb ref \\
            -i index.idx \\
            -g t2g.txt \\
            -f1 cdna.fa \\
            -f2 intron.fa \\
            -c1 cdna_t2c.txt \\
            -c2 intron_t2c.txt \\
            --workflow $workflow_mode \\
            $extra_args \\
            $fasta $gtf 2>&1 | tee kb_ref.log

        # Record the kb-python / kallisto / bustools versions used to build this
        # reference. kb-python has no --version flag and `kb info` exits non-zero
        # even on success, so tolerate the exit code and keep its first three
        # lines (kb_python / kallisto / bustools versions).
        kb info > kb_info.txt 2>&1 || true
        head -n 3 kb_info.txt > versions.txt
        rm -f kb_info.txt
        """
    }

    stub:
    def workflow_mode = params.kb_workflow ?: 'standard'
    if (workflow_mode == 'standard') {
        """
        touch index.idx t2g.txt cdna.fa versions.txt
        """
    } else {
        """
        touch index.idx t2g.txt cdna.fa intron.fa cdna_t2c.txt intron_t2c.txt versions.txt
        """
    }
}
