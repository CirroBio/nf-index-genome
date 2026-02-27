#!/usr/bin/env bash
# Install nf-core modules required by nf-index-genome.
# Requires nf-core tools: pip install nf-core
# Run from the repo root.

set -euo pipefail
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

MODULES=(
    bowtie2/build
    star/genomegenerate
    bismark/genomepreparation
    bwa/index
    hisat2/build
)

echo "Installing nf-core modules into $REPO_ROOT/modules/ ..."
for mod in "${MODULES[@]}"; do
    echo "  - $mod"
    nf-core modules install "$mod" --force 2>/dev/null || nf-core modules install "$mod"
done
echo "Done. You can run the workflows with nextflow run main_<tool>.nf --fasta <genome.fa> ..."
