# nf-index-genome

Nextflow workflows for building genome and transcriptome indices. Each tool has its own entrypoint (`main_<tool>.nf`) that runs the corresponding indexing process.

---

## Shared behavior

The following behaviors are common to all (or most) workflows. When reading per-tool details below, these can be assumed unless otherwise noted.

### Common inputs

| Parameter | Required by | Description |
|---|---|---|
| `--fasta` | all tools | Genome FASTA (gzipped or uncompressed) |
| `--gtf` | STAR (required); Bowtie2, BWA, Bismark, Kallisto, RSEM (optional, published only or used for transcriptome) | Gene annotation GTF |
| `--outdir` | all tools | Output directory (default: `./results`) |
| `--container` | all tools | Container image for the indexing tool |

### Input decompression

All workflows transparently handle gzipped (`.gz`) or uncompressed FASTA and GTF inputs. The pattern used throughout is:

```bash
gzip -t $file 2>/dev/null && gzip -cd $file > file.tmp || cp $file file.tmp
```

### Always-published outputs

Every workflow publishes the following files regardless of other options:

| File | Source |
|---|---|
| `genome.fasta` | `PUBLISH_FASTA` — publishes the input FASTA uncompressed (decompressing if needed), then runs `samtools faidx` on it |
| `genome.fasta.fai` | `PUBLISH_FASTA` — `samtools faidx` index of the FASTA |
| `versions.txt` | Written by each indexing process |

When `--gtf` is provided, all workflows additionally publish the annotation in both GTF and GFF3 form:

| File | Source |
|---|---|
| `genome.gtf` | `PUBLISH_GTF` — decompresses the input GTF if needed and sorts the feature records by sequence name and start position (uncompressed copy of the sorted annotation) |
| `genome.gtf.gz` | `PUBLISH_GTF` — bgzip-compresses the sorted `genome.gtf` |
| `genome.gtf.gz.tbi` | `PUBLISH_GTF` — `tabix -p gff` index of the bgzip-compressed GTF |
| `genome.gff3.gz` | `MAKE_GFF3` — `GFFREAD_GFF3` converts the GTF to GFF3 (`gffread genome.gtf -o genome.gff3`), then `PUBLISH_GFF3` sorts and bgzip-compresses it |
| `genome.gff3.gz.tbi` | `MAKE_GFF3` — `tabix -p gff` index of the bgzip-compressed GFF3 |

### Transcriptome FASTA generation

Three workflows (Bowtie2, Kallisto, Salmon) build a transcriptome FASTA from the genome + GTF as an intermediate step. The tool is controlled by `--transcriptome_source`:

| Value | Tool | Method |
|---|---|---|
| `gffread` (default) | gffread v0.12.7 | `gffread genome.gtf -g genome.fasta -w transcriptome.fasta` — extracts transcript sequences using genomic coordinates; handles prokaryotic annotations lacking `exon` features |
| `rsem` | rsem-prepare-reference | `rsem-prepare-reference --gtf genome.gtf genome.fasta rsem_ref/genome` — produces `rsem_ref/genome.transcripts.fa`; the standard approach for eukaryotic annotations |

The container for gffread is set separately via `--gffread_container` (default: `quay.io/biocontainers/gffread:0.12.7--h077b44d_6`). When `--transcriptome_source rsem`, `--container` must point to an RSEM image.

Both tools emit an uncompressed transcript FASTA, which `BGZIP_TRANSCRIPTOME` then bgzip-compresses (BGZF) to the `transcriptome.fasta.gz` consumed and published by the downstream index step. bgzip runs in the htslib container set via `--bgzip_container` (default: `quay.io/biocontainers/htslib:1.21--h566b1c6_1`).

`PUBLISH_FASTA` publishes the genome FASTA uncompressed (decompressing the input if needed) and then runs `samtools faidx` on it, in the samtools container set via `--samtools_container` (default: `quay.io/biocontainers/samtools:1.21--h50ea8bc_0`).

---

## Tools

### Bowtie2

**Entrypoint:** `main_bowtie2.nf`  
**Index type:** Short-read DNA alignment index (`.bt2` / `.bt2l` files)

#### Parameters

| Parameter | Required | Description |
|---|---|---|
| `--fasta` | yes | Genome FASTA |
| `--gtf` | no | GTF for transcriptome index |
| `--container` | yes | Bowtie2 container image |
| `--transcriptome_source` | no | `gffread` (default) or `rsem` |
| `--bowtie2_extra_args` | no | Extra flags passed to `bowtie2-build` |

#### Processing steps

Exactly one index is built per run — genome and transcriptome are mutually exclusive:

- **No `--gtf`** → genome index: `bowtie2-build --threads N <genome.fasta> genome` — prefix `genome`, log `bowtie2_build_genome.log`
- **With `--gtf`** → transcriptome FASTA via [MAKE_TRANSCRIPTOME](#transcriptome-fasta-generation), then transcriptome index: `bowtie2-build --threads N <transcriptome.fasta.gz> transcriptome` — prefix `transcriptome`, log `bowtie2_build_transcriptome.log`

`PUBLISH_FASTA` always runs; `PUBLISH_GTF` and `MAKE_GFF3` run when `--gtf` is provided.

#### Outputs

| File | Condition |
|---|---|
| `genome.1.bt2`, `genome.2.bt2`, … | no `--gtf` |
| `transcriptome.1.bt2`, `transcriptome.2.bt2`, … | with `--gtf` |
| `transcriptome.fasta.gz` | with `--gtf` |
| `genome.fasta` | always |
| `genome.fasta.fai` | always |
| `genome.gtf` | with `--gtf` |
| `genome.gtf.gz` | with `--gtf` |
| `genome.gtf.gz.tbi` | with `--gtf` |
| `genome.gff3.gz` | with `--gtf` |
| `genome.gff3.gz.tbi` | with `--gtf` |
| `bowtie2_build_genome.log` | no `--gtf` |
| `bowtie2_build_transcriptome.log` | with `--gtf` |
| `versions.txt` | always |

---

### BWA

**Entrypoint:** `main_bwa.nf`  
**Index type:** Short-read DNA alignment index

#### Parameters

| Parameter | Required | Description |
|---|---|---|
| `--fasta` | yes | Genome FASTA |
| `--gtf` | no | GTF (published only; not used for indexing) |
| `--container` | yes | BWA container image |
| `--bwa_extra_args` | no | Extra flags passed to `bwa index` |

#### Processing steps

1. **Genome index**: `bwa index -p genome <genome.fasta>` — prefix `genome`, log `bwa_index.log`
2. `PUBLISH_FASTA` and (if `--gtf`) `PUBLISH_GTF` + `MAKE_GFF3`

#### Outputs

| File | Condition |
|---|---|
| `genome.amb`, `genome.ann`, `genome.bwt`, `genome.pac`, `genome.sa` | always |
| `genome.fasta` | always |
| `genome.fasta.fai` | always |
| `genome.gtf` | if `--gtf` |
| `genome.gtf.gz` | if `--gtf` |
| `genome.gtf.gz.tbi` | if `--gtf` |
| `genome.gff3.gz` | if `--gtf` |
| `genome.gff3.gz.tbi` | if `--gtf` |
| `bwa_index.log` | always |
| `versions.txt` | always |

---

### bwa-mem2

**Entrypoint:** `main_bwamem2.nf`  
**Index type:** Short-read DNA alignment index (faster successor to BWA)

bwa-mem2 is a drop-in replacement for BWA-MEM with identical usage but significantly faster indexing and alignment through SIMD acceleration. The index requires approximately 28N GB of memory where N is the size of the reference sequence in GB.

#### Parameters

| Parameter | Required | Description |
|---|---|---|
| `--fasta` | yes | Genome FASTA |
| `--gtf` | no | GTF (published only; not used for indexing) |
| `--container` | yes | bwa-mem2 container image |
| `--bwamem2_extra_args` | no | Extra flags passed to `bwa-mem2 index` |

#### Processing steps

1. **Genome index**: `bwa-mem2 index -p genome <genome.fasta>` — prefix `genome`, log `bwamem2_index.log`
2. `PUBLISH_FASTA` and (if `--gtf`) `PUBLISH_GTF` + `MAKE_GFF3`

#### Outputs

| File | Condition |
|---|---|
| `genome.0123`, `genome.amb`, `genome.ann`, `genome.bwt.2bit.64`, `genome.pac` | always |
| `genome.fasta` | always |
| `genome.fasta.fai` | always |
| `genome.gtf` | if `--gtf` |
| `genome.gtf.gz` | if `--gtf` |
| `genome.gtf.gz.tbi` | if `--gtf` |
| `genome.gff3.gz` | if `--gtf` |
| `genome.gff3.gz.tbi` | if `--gtf` |
| `bwamem2_index.log` | always |
| `versions.txt` | always |

---

### HISAT2

**Entrypoint:** `main_hisat2.nf`  
**Index type:** Splice-aware RNA/DNA alignment index (`.ht2` files)

HISAT2 uses a separate GTF parameter (`--hisat2_gtf`) from the generic `--gtf` used by other tools. This is because it runs its own Python extraction scripts on the GTF rather than passing it directly to the indexer.

#### Parameters

| Parameter | Required | Description |
|---|---|---|
| `--fasta` | yes | Genome FASTA |
| `--hisat2_gtf` | no | GTF — auto-extracts splice sites and exons; mutually exclusive with `--hisat2_ss`/`--hisat2_exon` |
| `--hisat2_ss` | no | Pre-computed splice sites file (`.ss`); ignored if `--hisat2_gtf` given |
| `--hisat2_exon` | no | Pre-computed exon file (`.exon`); ignored if `--hisat2_gtf` given |
| `--hisat2_snp` | no | SNP file for SNP-aware indexing |
| `--hisat2_haplotype` | no | Haplotype file for haplotype-aware indexing |
| `--container` | yes | HISAT2 container image |
| `--hisat2_extra_args` | no | Extra flags passed to `hisat2-build` |

#### Processing steps

1. **Splice sites / exons** (if `--hisat2_gtf`):
   - `hisat2_extract_splice_sites.py annotation.gtf > splice_sites.ss`
   - `hisat2_extract_exons.py annotation.gtf > exons.exon`
   - If `--hisat2_gtf` is not given, uses `--hisat2_ss` / `--hisat2_exon` directly, or creates empty placeholder files if those are also absent.
2. **SNP / haplotype**: uses provided files or creates empty placeholders if absent.
3. **Genome index**: `hisat2-build -p N [--ss] [--exon] [--snp] [--haplotype] <genome.fasta> genome` — prefix `genome`, log `hisat2_build.log`
4. `PUBLISH_FASTA` and (if `--hisat2_gtf`) `PUBLISH_GTF` + `MAKE_GFF3`

#### Outputs

| File | Condition |
|---|---|
| `genome.1.ht2`, `genome.2.ht2`, … (up to 8) | always |
| `genome.fasta` | always |
| `genome.fasta.fai` | always |
| `genome.gtf` | if `--hisat2_gtf` |
| `genome.gtf.gz` | if `--hisat2_gtf` |
| `genome.gtf.gz.tbi` | if `--hisat2_gtf` |
| `genome.gff3.gz` | if `--hisat2_gtf` |
| `genome.gff3.gz.tbi` | if `--hisat2_gtf` |
| `hisat2_build.log` | always |
| `versions.txt` | always |

---

### STAR

**Entrypoint:** `main_star.nf`  
**Index type:** Splice-aware RNA alignment index (STAR genome directory)

#### Parameters

| Parameter | Required | Description |
|---|---|---|
| `--fasta` | yes | Genome FASTA |
| `--gtf` | yes | GTF for splice junction database |
| `--container` | yes | STAR container image |
| `--star_extra_args` | no | Extra flags passed to `STAR --runMode genomeGenerate` |

#### Processing steps

1. Decompress GTF if needed.
2. **Genome index**: `STAR --runMode genomeGenerate --sjdbGTFfile sjdb.gtf --genomeFastaFiles <genome.fasta> --runThreadN N` — log `star_genomegenerate.log`
3. `PUBLISH_FASTA`, `PUBLISH_GTF`, and `MAKE_GFF3`

#### Outputs

| File | Condition |
|---|---|
| STAR genome directory files (`Genome`, `SA`, `SAindex`, `chrName.txt`, etc.) | always |
| `genome.gtf` | always (GTF is required) |
| `genome.gtf.gz` | always (GTF is required) |
| `genome.gtf.gz.tbi` | always (GTF is required) |
| `genome.gff3.gz` | always (GTF is required) |
| `genome.gff3.gz.tbi` | always (GTF is required) |
| `genome.fasta` | always |
| `genome.fasta.fai` | always |
| `star_genomegenerate.log` | always |
| `versions.txt` | always |

---

### Salmon

**Entrypoint:** `main_salmon.nf`  
**Index type:** Quasi-mapping transcriptome index with full-genome decoys (`salmon_index/` directory)

#### Parameters

| Parameter | Required | Description |
|---|---|---|
| `--fasta` | yes | Genome FASTA |
| `--gtf` | yes | GTF for transcriptome generation |
| `--container` | yes | Salmon container image |
| `--extra_fasta` | no | Additional FASTA concatenated into transcript targets before indexing (default: empty placeholder) |
| `--transcriptome_source` | no | `gffread` (default) or `rsem` |
| `--gffread_container` | no | gffread container (used when `transcriptome_source = gffread`) |
| `--salmon_extra_args` | no | Extra flags passed to `salmon index` |

#### Processing steps

1. **Transcriptome FASTA**: see [Transcriptome FASTA generation](#transcriptome-fasta-generation) — produces `transcriptome.fasta.gz`
2. **Decoy-aware index** (always, since genome is always provided):
   - Decompress transcriptome FASTA → `transcripts.fasta`
   - If `--extra_fasta` is non-empty: concatenate into `transcripts.fasta`
   - Decompress genome FASTA → `genome.fasta`
   - Extract decoy names: `grep '^>' genome.fasta | cut -d ' ' -f 1 | sed 's/>//g' > decoys.txt`
   - Build gentrome (transcripts first, required by Salmon): `cat transcripts.fasta genome.fasta > gentrome.fasta`
   - Index: `salmon index --threads N -t gentrome.fasta -d decoys.txt -i salmon_index` — log `salmon_index.log`
3. `PUBLISH_FASTA`, `PUBLISH_GTF`, and `MAKE_GFF3`

**Why decoys?** Reads from intergenic/intronic regions can be spuriously assigned to the nearest transcript. Providing the whole genome as a decoy lets Salmon recognize and discard these reads during quantification, improving accuracy.

#### Outputs

| File | Condition |
|---|---|
| `salmon_index/` (directory with index files) | always |
| `genome.fasta` | always |
| `genome.fasta.fai` | always |
| `genome.gtf` | always (GTF is required) |
| `genome.gtf.gz` | always (GTF is required) |
| `genome.gtf.gz.tbi` | always (GTF is required) |
| `genome.gff3.gz` | always (GTF is required) |
| `genome.gff3.gz.tbi` | always (GTF is required) |
| `salmon_index.log` | always |
| `versions.txt` | always |

---

### alevin-fry (simpleaf)

**Entrypoint:** `main_alevinfry.nf`  
**Index type:** Spliced+intron (splici) decoy-aware reference index built by `simpleaf index` (piscem indexer by default), with a transcript-to-gene map for alevin-fry USA-mode quantification (`simpleaf/` directory)

This is the alevin-fry counterpart to the [Salmon](#salmon) workflow. Unlike bare `salmon index`, `simpleaf` constructs the splici reference and the t2g map internally from the genome and GTF (via roers), so it does not use the shared [transcriptome generation](#transcriptome-fasta-generation) step.

#### Parameters

| Parameter | Required | Description |
|---|---|---|
| `--fasta` | yes | Genome FASTA |
| `--gtf` | yes | GTF used to build the splici reference |
| `--container` | yes | simpleaf container image (bundles simpleaf, alevin-fry, piscem, salmon) |
| `--simpleaf_extra_args` | no | Extra flags passed to `simpleaf index` (e.g. `--use-salmon` to index with salmon instead of piscem) |

#### Processing steps

1. Decompress genome FASTA and GTF if gzipped (roers requires uncompressed inputs).
2. **Reference index**: `simpleaf index --threads N --fasta genome.fasta --gtf genome.gtf --output simpleaf` — builds `simpleaf/ref/` (splici reference + t2g maps) and `simpleaf/index/` (piscem index).
3. `PUBLISH_FASTA`, `PUBLISH_GTF`, and `MAKE_GFF3`.

#### Outputs

| File | Condition |
|---|---|
| `simpleaf/index/` (piscem index files) | always |
| `simpleaf/ref/` (splici reference FASTA + `t2g.tsv`/`t2g_3col.tsv`) | always |
| `genome.fasta` | always |
| `genome.fasta.fai` | always |
| `genome.gtf` | always (GTF is required) |
| `genome.gtf.gz` | always (GTF is required) |
| `genome.gtf.gz.tbi` | always (GTF is required) |
| `genome.gff3.gz` | always (GTF is required) |
| `genome.gff3.gz.tbi` | always (GTF is required) |
| `versions.txt` | always |

---

### Kallisto

**Entrypoint:** `main_kallisto.nf`  
**Index type:** k-mer pseudoalignment index (`.idx` file)

#### Parameters

| Parameter | Required | Description |
|---|---|---|
| `--fasta` | yes | Genome FASTA |
| `--gtf` | no | GTF for transcriptome index |
| `--container` | yes | Kallisto container image |
| `--transcriptome_source` | no | `gffread` (default) or `rsem` — only used if `--gtf` is provided |
| `--gffread_container` | no | gffread container (used when `transcriptome_source = gffread`) |
| `--kallisto_extra_args` | no | Extra flags passed to `kallisto index` |

#### Processing steps

1. **Genome index** (always): `kallisto index -i genome.idx <genome.fasta>` — log `kallisto_index_genome.log`
2. If `--gtf`:
   - **Transcriptome FASTA**: see [Transcriptome FASTA generation](#transcriptome-fasta-generation) — produces `transcriptome.fasta.gz`
   - **Transcriptome index**: `kallisto index -i transcriptome.idx <transcriptome.fasta.gz>` — log `kallisto_index_transcriptome.log`
   - Publish `transcriptome.fasta.gz`
3. `PUBLISH_FASTA` and (if `--gtf`) `PUBLISH_GTF` + `MAKE_GFF3`

#### Outputs

| File | Condition |
|---|---|
| `genome.idx` | always |
| `transcriptome.idx` | if `--gtf` |
| `transcriptome.fasta.gz` | if `--gtf` |
| `genome.fasta` | always |
| `genome.fasta.fai` | always |
| `genome.gtf` | if `--gtf` |
| `genome.gtf.gz` | if `--gtf` |
| `genome.gtf.gz.tbi` | if `--gtf` |
| `genome.gff3.gz` | if `--gtf` |
| `genome.gff3.gz.tbi` | if `--gtf` |
| `kallisto_index_genome.log` | always |
| `kallisto_index_transcriptome.log` | if `--gtf` |
| `versions.txt` | always |

---

### kallisto | bustools (kb)

**Entrypoint:** `main_kb.nf`  
**Index type:** kallisto pseudoalignment index plus a transcript-to-gene map and cDNA FASTA built by `kb ref` (kb-python), for single-cell BUStools quantification

This is the kallisto|bustools counterpart to the [Kallisto](#kallisto) workflow. Unlike bare `kallisto index`, `kb ref` also emits the `t2g.txt` map (and, in RNA-velocity mode, intron references) that BUStools requires. kb-python reads gzipped inputs directly, so no decompression step is needed.

#### Parameters

| Parameter | Required | Description |
|---|---|---|
| `--fasta` | yes | Genome FASTA |
| `--gtf` | yes | GTF used to extract cDNA (and intron) sequences |
| `--container` | yes | kb-python container image |
| `--kb_workflow` | no | `standard` (default) or `nac`/`lamanno` to additionally build intron references for RNA-velocity |
| `--kb_extra_args` | no | Extra flags passed to `kb ref` |

#### Processing steps

1. **Reference** (`standard`): `kb ref -i index.idx -g t2g.txt -f1 cdna.fa --workflow standard <fasta> <gtf>` — log `kb_ref.log`.
2. **Reference** (`nac`/`lamanno`): additionally emits `-f2 intron.fa -c1 cdna_t2c.txt -c2 intron_t2c.txt`.
3. `PUBLISH_FASTA`, `PUBLISH_GTF`, and `MAKE_GFF3`.

#### Outputs

| File | Condition |
|---|---|
| `index.idx` | always |
| `t2g.txt` | always |
| `cdna.fa` | always |
| `intron.fa` | if `--kb_workflow nac`/`lamanno` |
| `cdna_t2c.txt` | if `--kb_workflow nac`/`lamanno` |
| `intron_t2c.txt` | if `--kb_workflow nac`/`lamanno` |
| `genome.fasta` | always |
| `genome.fasta.fai` | always |
| `genome.gtf` | always (GTF is required) |
| `genome.gtf.gz` | always (GTF is required) |
| `genome.gtf.gz.tbi` | always (GTF is required) |
| `genome.gff3.gz` | always (GTF is required) |
| `genome.gff3.gz.tbi` | always (GTF is required) |
| `kb_ref.log` | always |
| `versions.txt` | always |

---

### Cell Ranger

**Entrypoint:** `main_cellranger.nf`  
**Index type:** 10x Genomics reference package built by `cellranger mkref` (runs STAR genomeGenerate internally); directory named by `--cellranger_reference_name`

> Cell Ranger is proprietary 10x Genomics software. This workflow uses a public prebuilt image (`quay.io/cumulus/cellranger`, maintained by the Cumulus project); its use is subject to the 10x Genomics End User License Agreement. It does not support Conda.

#### Parameters

| Parameter | Required | Description |
|---|---|---|
| `--fasta` | yes | Genome FASTA (gzipped or uncompressed) |
| `--gtf` | yes | Gene annotation GTF (gzipped or uncompressed) |
| `--container` | yes | Cell Ranger container image (e.g. `quay.io/cumulus/cellranger:10.0.0`) |
| `--cellranger_reference_name` | no | Output reference directory name (default: `cellranger_reference`) |
| `--cellranger_mkref_args` | no | Extra flags passed to `cellranger mkref` |
| `--cellranger_mkgtf_args` | no | If set, filter the GTF with `cellranger mkgtf` first (e.g. `--attribute=gene_biotype:protein_coding`); if empty (default), mkref runs on the GTF as-is |

#### Processing steps

1. If `--cellranger_mkgtf_args` is set: `cellranger mkgtf <gtf> genes.filtered.gtf <args>` — slim the GTF by attribute (the filtered GTF feeds mkref; the original GTF is still published).
2. Decompress FASTA and GTF if gzipped (mkref requires uncompressed inputs).
3. **Reference**: `cellranger mkref --genome=<name> --fasta=genome.fasta --genes=<gtf> --localcores=N --localmem=<GiB> --nthreads=N` — produces `<name>/{fasta,genes,star,reference.json}`.
4. `PUBLISH_FASTA`, `PUBLISH_GTF`, and `MAKE_GFF3`.

#### Outputs

| File | Condition |
|---|---|
| `<cellranger_reference_name>/fasta/genome.fa` (+ `.fai`) | always |
| `<cellranger_reference_name>/genes/genes.gtf.gz` | always |
| `<cellranger_reference_name>/star/` (STAR index) | always |
| `<cellranger_reference_name>/reference.json` | always |
| `genes.filtered.gtf` | if `--cellranger_mkgtf_args` |
| `genome.fasta` | always |
| `genome.fasta.fai` | always |
| `genome.gtf` | always (GTF is required) |
| `genome.gtf.gz` | always (GTF is required) |
| `genome.gtf.gz.tbi` | always (GTF is required) |
| `genome.gff3.gz` | always (GTF is required) |
| `genome.gff3.gz.tbi` | always (GTF is required) |
| `versions.txt` | always |

---

### RSEM

**Entrypoint:** `main_rsem.nf`  
**Index type:** RSEM reference (`rsem_index/` directory)

#### Parameters

| Parameter | Required | Description |
|---|---|---|
| `--fasta` | yes | Genome FASTA |
| `--gtf` | yes | GTF passed to `rsem-prepare-reference --gtf` to define transcript boundaries |
| `--container` | yes | RSEM container image |
| `--rsem_extra_args` | no | Extra flags passed to `rsem-prepare-reference` |

#### Processing steps

1. Decompress GTF if gzipped.
2. **RSEM reference**: `rsem-prepare-reference --gtf genome.gtf <extra_args> <fasta> rsem_index/genome` — log `rsem_prepare_reference.log`
3. `PUBLISH_FASTA`, `PUBLISH_GTF`, and `MAKE_GFF3`

#### Outputs

| File | Condition |
|---|---|
| `rsem_index/` (directory: `genome.grp`, `genome.ti`, `genome.transcripts.fa`, etc.) | always |
| `genome.fasta` | always |
| `genome.fasta.fai` | always |
| `genome.gtf` | always (GTF is required) |
| `genome.gtf.gz` | always (GTF is required) |
| `genome.gtf.gz.tbi` | always (GTF is required) |
| `genome.gff3.gz` | always (GTF is required) |
| `genome.gff3.gz.tbi` | always (GTF is required) |
| `rsem_prepare_reference.log` | always |
| `versions.txt` | always |

---

### Bismark

**Entrypoint:** `main_bismark.nf`  
**Index type:** Bisulfite-converted genome index (`genome/Bisulfite_Genome/` directory)

#### Parameters

| Parameter | Required | Description |
|---|---|---|
| `--fasta` | yes | Genome FASTA |
| `--aligner` | yes | `bowtie2` or `hisat2` — determines which aligner Bismark builds the index for |
| `--gtf` | no | GTF (published only; not used for indexing) |
| `--container` | yes | Bismark container image |
| `--bismark_extra_args` | no | Extra flags passed to `bismark_genome_preparation` |

#### Processing steps

1. Stage the genome FASTA inside a `genome/` subdirectory (required by `bismark_genome_preparation`).
2. **Bisulfite index**: `bismark_genome_preparation --[bowtie2|hisat2] --parallel N --genomic_composition genome/` — log `bismark_genome_preparation.log`
3. `PUBLISH_FASTA` and (if `--gtf`) `PUBLISH_GTF` + `MAKE_GFF3`

#### Outputs

| File | Condition |
|---|---|
| `genome/Bisulfite_Genome/` (CT and GA conversion index files) | always |
| `genome/` (original FASTA and genome composition file) | always |
| `genome.fasta` | always |
| `genome.fasta.fai` | always |
| `genome.gtf` | if `--gtf` |
| `genome.gtf.gz` | if `--gtf` |
| `genome.gtf.gz.tbi` | if `--gtf` |
| `genome.gff3.gz` | if `--gtf` |
| `genome.gff3.gz.tbi` | if `--gtf` |
| `bismark_genome_preparation.log` | always |
| `versions.txt` | always |

---

## Setup

1. **Install Nextflow** (>= 24.04.0).

2. **Modules**: All required modules are bundled under `modules/`. To update modules from nf-core (optional):

   ```bash
   pip install nf-core
   ./scripts/install_modules.sh
   ```

## Usage

```bash
# Bowtie2 — genome index only
nextflow run main_bowtie2.nf --fasta genome.fa --outdir results/ --container biocontainers/bowtie2:2.5.1

# Bowtie2 — genome + transcriptome index
nextflow run main_bowtie2.nf --fasta genome.fa --gtf genes.gtf --outdir results/ --container biocontainers/bowtie2:2.5.1

# BWA
nextflow run main_bwa.nf --fasta genome.fa --outdir results/ --container biocontainers/bwa:0.7.17

# bwa-mem2
nextflow run main_bwamem2.nf --fasta genome.fa --outdir results/ --container biocontainers/bwa-mem2:2.2.1

# HISAT2 — splice-aware (GTF auto-extracts splice sites and exons)
nextflow run main_hisat2.nf --fasta genome.fa --hisat2_gtf genes.gtf --outdir results/ --container biocontainers/hisat2:2.2.1

# STAR
nextflow run main_star.nf --fasta genome.fa --gtf genes.gtf --outdir results/ --container biocontainers/star:2.7.10a

# Salmon — decoy-aware (genome + GTF, gffread for transcriptome)
nextflow run main_salmon.nf --fasta genome.fa --gtf genes.gtf --outdir results/ --container biocontainers/salmon:1.10.3

# Salmon — using RSEM to generate transcriptome FASTA
nextflow run main_salmon.nf --fasta genome.fa --gtf genes.gtf --transcriptome_source rsem --outdir results/ --container biocontainers/rsem:1.3.3

# Salmon / alevin-fry — splici reference via simpleaf (piscem index + t2g map)
nextflow run main_alevinfry.nf --fasta genome.fa --gtf genes.gtf --outdir results/ --container quay.io/biocontainers/simpleaf:0.19.5--ha6fb395_0

# Kallisto — genome index only
nextflow run main_kallisto.nf --fasta genome.fa --outdir results/ --container biocontainers/kallisto:0.50.1

# Kallisto — genome + transcriptome index
nextflow run main_kallisto.nf --fasta genome.fa --gtf genes.gtf --outdir results/ --container biocontainers/kallisto:0.50.1

# kallisto | bustools — kb ref (kallisto index + t2g map for single-cell)
nextflow run main_kb.nf --fasta genome.fa --gtf genes.gtf --outdir results/ --container quay.io/biocontainers/kb-python:0.28.2--pyhdfd78af_2

# kallisto | bustools — RNA-velocity reference (intron references)
nextflow run main_kb.nf --fasta genome.fa --gtf genes.gtf --kb_workflow nac --outdir results/ --container quay.io/biocontainers/kb-python:0.28.2--pyhdfd78af_2

# Cell Ranger — 10x reference (subject to 10x Genomics EULA)
nextflow run main_cellranger.nf --fasta genome.fa --gtf genes.gtf --outdir results/ --container quay.io/cumulus/cellranger:10.0.0

# RSEM
nextflow run main_rsem.nf --fasta transcriptome.fa --outdir results/ --container biocontainers/rsem:1.3.3

# Bismark (bowtie2 backend)
nextflow run main_bismark.nf --fasta genome.fa --aligner bowtie2 --outdir results/ --container biocontainers/bismark:0.24.0
```

## Testing

Tests use nf-core test data from [nf-core/test-datasets](https://github.com/nf-core/test-datasets) (branch `modules`), pulled via HTTP at runtime.

**Run all tests (requires [nf-test](https://www.nf-test.com/)):**

```bash
nf-test test
```

Run only stub tests (no real indexing, fast; no Docker needed):

```bash
nf-test test --tag stub
```

Run a single workflow's tests:

```bash
nf-test test tests/workflows/main_bowtie2.nf.test
```

Update snapshots after intentional behavior changes:

```bash
nf-test test --update-snapshot
```

## Project structure

```
main_<tool>.nf           # Entrypoints — parameter validation + workflow call
workflows/<tool>.nf      # Workflow definitions
workflows/make_transcriptome.nf  # Shared subworkflow for transcriptome FASTA generation
workflows/make_gff3.nf   # Shared subworkflow: GTF -> GFF3, bgzip + tabix
modules/<tool>*.nf       # Process definitions (one or more per tool)
modules/publish_fasta.nf # Shared: publish genome.fasta
modules/publish_gtf.nf   # Shared: publish genome.gtf + genome.gtf.gz (bgzip) + tabix index
modules/gffread_gff3.nf  # Shared: convert GTF to GFF3 via gffread
modules/publish_gff3.nf  # Shared: publish genome.gff3.gz (bgzip) + tabix index
modules/gffread.nf       # Shared: transcriptome extraction via gffread
modules/rsem_transcript_fasta.nf  # Shared: transcriptome extraction via RSEM
assets/extra.fasta       # Empty placeholder used as default for --extra_fasta (Salmon)
tests/config/            # Test config and nf-core test data URLs
tests/workflows/         # nf-test workflow tests (one *.nf.test per entrypoint)
```

## Maintaining this documentation

**When you change any workflow or module, update the corresponding section in this README.**

Specifically:
- Adding or removing a parameter → update the Parameters table for that tool
- Changing a processing step → update the Processing steps list for that tool
- Adding or removing an output file → update the Outputs table for that tool
- Adding a new tool → add a new subsection following the existing format
- Changing shared behavior (PUBLISH_FASTA, PUBLISH_GTF, MAKE_GFF3, transcriptome generation) → update the [Shared behavior](#shared-behavior) section
