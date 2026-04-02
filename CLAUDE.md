# Development guidelines

## Keeping README.md up to date

**README.md is the source of truth for how every indexing tool behaves.** Whenever you change a workflow or module, you must update the corresponding section in README.md in the same edit.

| What changed | Where to update in README.md |
|---|---|
| Parameter added, removed, or renamed | Parameters table for that tool |
| Processing step added, changed, or removed | Processing steps list for that tool |
| Output file added, removed, or renamed | Outputs table for that tool |
| New tool added | New subsection following the existing format |
| Shared behavior changed (PUBLISH_FASTA, PUBLISH_GTF, transcriptome generation) | "Shared behavior" section |

The `workflows/make_transcriptome.nf` subworkflow is shared by Bowtie2, Kallisto, and Salmon — changes there affect all three tools' documentation.
