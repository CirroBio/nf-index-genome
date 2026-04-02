# PROJECT_INDEX.md — nf-index-genome

Generated: 2026-04-01

---

## 1. Project Purpose and Overview

**nf-index-genome** is a collection of Nextflow (DSL2) pipelines for building genome and transcriptome indices. Each supported alignment/quantification tool is exposed as a separate, independently runnable entrypoint. The project is authored by Sam Minot at Cirro Bio and uses custom process modules modelled after nf-core/modules conventions.

### Supported tools

| Tool | Index type | Use case |
|---|---|---|
| Bowtie2 | DNA/short-read genome index (`.bt2` files) | DNA alignment |
| STAR | Splice-aware RNA-seq genome index | RNA-seq alignment |
| Bismark | Bisulfite-converted genome index | Bisulfite/methylation sequencing |
| BWA | BWT genome index | DNA alignment |
| HISAT2 | Splice-aware genome index (optional SNP/haplotype support) | RNA-seq alignment |
| Salmon | k-mer transcriptome index | Transcript-level RNA quantification |
| Kallisto | k-mer transcriptome index | Transcript-level RNA quantification |
| RSEM | RSEM reference (transcript + genome) | RNA-seq quantification |

### Key design decisions
- Each tool is an **independent entrypoint** (`main_<tool>.nf`) so users can run only what they need.
- All workflows publish a canonical `genome.fasta.gz` (and `genome.gtf` where applicable) alongside the index, making the output directory self-contained for downstream pipelines.
- Inputs may be compressed (`.gz`) or uncompressed; modules handle decompression internally.
- Container images are supplied at runtime via `--container`; the project does not pin specific images in config, making it easy to use custom builds.
- HISAT2 supports full optional annotation via GTF auto-extraction of splice sites and exons (or direct file inputs).
- Salmon and Kallisto share a common upstream `GFFREAD` module to generate the transcriptome FASTA from the genome + GTF.

---

## 2. Directory Structure

```
nf-index-genome/
├── main_bismark.nf         # Entrypoint: Bismark bisulfite index
├── main_bowtie2.nf         # Entrypoint: Bowtie2 genome index
├── main_bwa.nf             # Entrypoint: BWA genome index
├── main_hisat2.nf          # Entrypoint: HISAT2 genome index
├── main_kallisto.nf        # Entrypoint: Kallisto transcriptome index
├── main_rsem.nf            # Entrypoint: RSEM reference preparation
├── main_salmon.nf          # Entrypoint: Salmon transcriptome index
├── main_star.nf            # Entrypoint: STAR genome index
├── nextflow.config         # Global config: manifest, default params, test profile
├── nf-test.config          # nf-test runner config (testsDir, workDir, configFile)
│
├── workflows/              # Workflow definitions (one per tool)
│   ├── bismark.nf          # BISMARK_INDEX workflow
│   ├── bowtie2.nf          # BOWTIE2_INDEX workflow
│   ├── bwa.nf              # BWA_INDEX_WORKFLOW workflow
│   ├── hisat2.nf           # HISAT2_INDEX workflow (includes placeholder processes)
│   ├── kallisto.nf         # KALLISTO_INDEX_WF workflow
│   ├── rsem.nf             # RSEM_INDEX workflow
│   ├── salmon.nf           # SALMON_INDEX_WF workflow
│   └── star.nf             # STAR_INDEX workflow
│
├── modules/                # Custom process modules
│   ├── bismark_genomepreparation.nf
│   ├── bowtie2_build.nf
│   ├── bwa_index.nf
│   ├── gffread.nf          # Transcriptome extraction (shared by Salmon + Kallisto)
│   ├── hisat2_build.nf
│   ├── kallisto_index.nf
│   ├── publish_fasta.nf    # Shared: canonicalise + publish genome.fasta.gz
│   ├── publish_gtf.nf      # Shared: canonicalise + publish genome.gtf
│   ├── rsem_preparereference.nf
│   ├── salmon_index.nf
│   └── star_genomegenerate.nf
│
├── tests/
│   ├── config/
│   │   ├── nextflow.config # nf-test Nextflow config (includes root config + test_data)
│   │   └── test_data.config # nf-core test data URLs (sarscov2, homo_sapiens)
│   └── workflows/          # nf-test workflow tests (one .nf.test per entrypoint)
│       ├── main_bismark.nf.test
│       ├── main_bowtie2.nf.test
│       ├── main_bowtie2.nf.test.snap  # snapshot file
│       ├── main_bwa.nf.test
│       ├── main_hisat2.nf.test
│       ├── main_kallisto.nf.test
│       ├── main_rsem.nf.test
│       ├── main_salmon.nf.test
│       └── main_star.nf.test
│
├── scripts/
│   ├── install_modules.sh  # Installs nf-core modules (optional update mechanism)
│   └── run_tests.sh        # Wrapper: runs nf-test test tests/workflows
│
└── assets/
    └── extra.fasta         # Optional extra sequences appended to Salmon transcriptome
```

---

## 3. Entrypoints

All entrypoints follow the same pattern: validate required params, then call the corresponding workflow. Every entrypoint requires `--fasta`, `--outdir`, and `--container`. Tool-specific extra requirements are noted below.

| File | Workflow called | Extra required params |
|---|---|---|
| `main_bowtie2.nf` | `BOWTIE2_INDEX` | — |
| `main_star.nf` | `STAR_INDEX` | `--gtf` |
| `main_bismark.nf` | `BISMARK_INDEX` | `--aligner` (e.g. `bowtie2`) |
| `main_bwa.nf` | `BWA_INDEX_WORKFLOW` | — |
| `main_hisat2.nf` | `HISAT2_INDEX` | — (many optional annotation params) |
| `main_salmon.nf` | `SALMON_INDEX_WF` | `--gtf` |
| `main_kallisto.nf` | `KALLISTO_INDEX_WF` | `--gtf` |
| `main_rsem.nf` | `RSEM_INDEX` | — |

---

## 4. Workflows

### BOWTIE2_INDEX (`workflows/bowtie2.nf`)
Processes: `BOWTIE2_BUILD`, `PUBLISH_FASTA`, optionally `PUBLISH_GTF`

Loads `--fasta`, builds the Bowtie2 index, then publishes `genome.fasta.gz`. If `--gtf` is set, the GTF is also published as `genome.gtf`.

### STAR_INDEX (`workflows/star.nf`)
Processes: `STAR_GENOMEGENERATE`, `PUBLISH_FASTA`

Loads both `--fasta` and `--gtf` (GTF is required for splice-junction support). GTF is published as `genome.gtf` inside the process itself; `PUBLISH_FASTA` publishes `genome.fasta.gz`.

### BISMARK_INDEX (`workflows/bismark.nf`)
Processes: `BISMARK_GENOMEPREPARATION`, `PUBLISH_FASTA`, optionally `PUBLISH_GTF`

Passes the genome directory into `bismark_genome_preparation`. The `--aligner` param (e.g. `bowtie2`) is passed through to the tool. Publishes FASTA and optionally the GTF.

### BWA_INDEX_WORKFLOW (`workflows/bwa.nf`)
Processes: `BWA_INDEX`, `PUBLISH_FASTA`, optionally `PUBLISH_GTF`

Builds a BWA BWT index with prefix `genome`. Publishes FASTA and optionally the GTF.

### HISAT2_INDEX (`workflows/hisat2.nf`)
Processes: `HISAT2_BUILD`, `PUBLISH_FASTA`, optionally `PUBLISH_GTF`; plus inline processes `HISAT2_EXTRACT_SPLICE_SITES`, `HISAT2_EXTRACT_EXONS`, `CREATE_PLACEHOLDER_{SS,EXON,SNP,HAPLOTYPE}`

The most complex workflow. The HISAT2 module requires path inputs for splice sites, exons, SNPs, and haplotypes even when unused. The workflow handles this by:
- If `--hisat2_gtf` is provided: extract splice sites and exons automatically via `hisat2_extract_splice_sites.py` / `hisat2_extract_exons.py` (mutually exclusive with `--hisat2_ss` / `--hisat2_exon`).
- If direct files are provided via `--hisat2_ss`, `--hisat2_exon`, `--hisat2_snp`, `--hisat2_haplotype`: those are used.
- Any missing optional inputs get a placeholder empty file (e.g. `empty.ss`) using `ubuntu:20.04` containers.

Note: `--gtf` in nextflow.config is a generic param; for HISAT2 the annotation-specific param is `--hisat2_gtf`.

### SALMON_INDEX_WF (`workflows/salmon.nf`)
Processes: `GFFREAD`, `SALMON_INDEX`, `PUBLISH_FASTA`, `PUBLISH_GTF`

1. `GFFREAD` extracts transcript sequences from `--fasta` + `--gtf` into `transcriptome.fasta.gz`.
2. `SALMON_INDEX` builds the salmon index. If `assets/extra.fasta` (controlled by `--extra_fasta`) has content (size > 2 bytes), it is concatenated with the transcriptome before indexing (useful for adding spike-in sequences or decoys).
3. Both the genome FASTA and GTF are published.

### KALLISTO_INDEX_WF (`workflows/kallisto.nf`)
Processes: `GFFREAD`, `KALLISTO_INDEX`, `PUBLISH_FASTA`, `PUBLISH_GTF`

Identical upstream to Salmon: `GFFREAD` generates the transcriptome from genome + GTF. `KALLISTO_INDEX` builds the kallisto index and also publishes `transcriptome.fasta.gz` as a convenience output.

### RSEM_INDEX (`workflows/rsem.nf`)
Processes: `RSEM_PREPAREREFERENCE`, `PUBLISH_FASTA`, optionally `PUBLISH_GTF`

Runs `rsem-prepare-reference` with output in a `rsem_index/` subdirectory under `--outdir`. Publishes FASTA and optionally GTF.

---

## 5. Modules

### Index-building modules

| Module file | Process name | Tool command | Output prefix/dir |
|---|---|---|---|
| `bowtie2_build.nf` | `BOWTIE2_BUILD` | `bowtie2-build` | `genome` (`.bt2` files) |
| `star_genomegenerate.nf` | `STAR_GENOMEGENERATE` | `STAR --runMode genomeGenerate` | `./` (current dir) |
| `bismark_genomepreparation.nf` | `BISMARK_GENOMEPREPARATION` | `bismark_genome_preparation` | `genome/` directory |
| `bwa_index.nf` | `BWA_INDEX` | `bwa index -p genome` | `genome` (`.amb`, `.ann`, `.bwt`, `.pac`, `.sa`) |
| `hisat2_build.nf` | `HISAT2_BUILD` | `hisat2-build` | `genome` (`.ht2` files) |
| `salmon_index.nf` | `SALMON_INDEX` | `salmon index` | `salmon_index/` directory |
| `kallisto_index.nf` | `KALLISTO_INDEX` | `kallisto index` | `kallisto_index.idx` |
| `rsem_preparereference.nf` | `RSEM_PREPAREREFERENCE` | `rsem-prepare-reference` | `rsem_index/genome` prefix |
| `gffread.nf` | `GFFREAD` | `gffread` | `transcriptome.fasta.gz` |

All index modules:
- Use `container "${params.container}"` (user-supplied image).
- Publish all outputs to `params.outdir` (mode: copy, overwrite: true).
- Support extra CLI args via `params.<tool>_extra_args`.
- Write a `versions.txt` capturing tool version.
- Capture tool stdout/stderr in a `<tool>_<command>.log` file.

### Shared utility modules

**`publish_fasta.nf` — `PUBLISH_FASTA`**
- Input: any FASTA path (compressed or not).
- Output: `genome.fasta.gz` published to `params.outdir`.
- Behaviour: if input is already gzip-compressed, copies as-is; otherwise compresses with `gzip -c`.
- Container: `ubuntu:20.04`.

**`publish_gtf.nf` — `PUBLISH_GTF`**
- Input: any GTF path (compressed or not).
- Output: `genome.gtf` (uncompressed) published to `params.outdir`.
- Behaviour: if input is gzip-compressed, decompresses; otherwise copies.
- Container: `ubuntu:20.04`.

**`gffread.nf` — `GFFREAD`**
- Input: genome FASTA + GTF (either may be gzip-compressed).
- Output: `transcriptome.fasta.gz` (emitted as named output `transcriptome`).
- Container: `params.gffread_container` (default: `quay.io/biocontainers/gffread:0.12.7--h077b44d_6`).
- Note: this module is NOT published to `outdir`; it is an intermediate step.

---

## 6. Parameters Reference

Defined in `nextflow.config` under `params {}`.

### Universal parameters (all workflows)

| Parameter | Default | Required | Description |
|---|---|---|---|
| `--fasta` | `null` | Yes | Path to reference genome FASTA (plain or `.gz`) |
| `--gtf` | `null` | Tool-dependent | Gene annotation GTF (plain or `.gz`). Required for STAR, Salmon, Kallisto. Optional for Bowtie2, BWA, Bismark, RSEM, HISAT2 (triggers GTF publishing when set). |
| `--outdir` | `./results` | Yes | Output directory for index files and canonical FASTA/GTF |
| `--container` | `null` | Yes | Docker/Singularity image for the index tool |

### Tool-specific parameters

| Parameter | Default | Description |
|---|---|---|
| `--aligner` | `null` | Bismark only: aligner backend, e.g. `bowtie2` or `hisat2` |
| `--hisat2_gtf` | `null` | HISAT2: GTF for auto-extraction of splice sites and exons |
| `--hisat2_ss` | `null` | HISAT2: pre-computed splice sites file (`.ss`) |
| `--hisat2_exon` | `null` | HISAT2: pre-computed exon file (`.exon`) |
| `--hisat2_snp` | `null` | HISAT2: SNP file (`.snp`) |
| `--hisat2_haplotype` | `null` | HISAT2: haplotype file (`.haplotype`) |
| `--hisat2_build_memory` | `16 GB` | Minimum memory to use GTF/splice-sites in HISAT2 index |
| `--extra_fasta` | `assets/extra.fasta` | Salmon: additional FASTA appended to transcriptome before indexing |
| `--gffread_container` | `quay.io/biocontainers/gffread:0.12.7--h077b44d_6` | Container for gffread (Salmon + Kallisto workflows) |

### Extra args pass-through

Each tool has a `--<tool>_extra_args` parameter (default `""`) forwarded verbatim to the tool's CLI:

| Parameter | Forwarded to |
|---|---|
| `--bismark_extra_args` | `bismark_genome_preparation` |
| `--bwa_extra_args` | `bwa index` |
| `--bowtie2_extra_args` | `bowtie2-build` |
| `--hisat2_extra_args` | `hisat2-build` |
| `--star_extra_args` | `STAR --runMode genomeGenerate` |
| `--salmon_extra_args` | `salmon index` |
| `--kallisto_extra_args` (note: not in config, but used in module) | `kallisto index` |
| `--rsem_extra_args` (note: not in config, but used in module) | `rsem-prepare-reference` |

---

## 7. Output Files per Workflow

Each workflow publishes to `--outdir`. All outputs are copies (not symlinks).

| Workflow | Published files |
|---|---|
| Bowtie2 | `genome.*.bt2` files, `bowtie2_build.log`, `versions.txt`, `genome.fasta.gz`, optionally `genome.gtf` |
| STAR | STAR index directory contents (many files), `star_genomegenerate.log`, `versions.txt`, `genome.gtf`, `genome.fasta.gz` |
| Bismark | `genome/` directory with bisulfite index, `bismark_genome_preparation.log`, `versions.txt`, `genome.fasta.gz`, optionally `genome.gtf` |
| BWA | `genome.amb`, `genome.ann`, `genome.bwt`, `genome.pac`, `genome.sa`, `bwa_index.log`, `versions.txt`, `genome.fasta.gz`, optionally `genome.gtf` |
| HISAT2 | `genome.*.ht2` files, `hisat2_build.log`, `versions.txt`, `genome.fasta.gz`, optionally `genome.gtf` |
| Salmon | `salmon_index/` directory, `salmon_index.log`, `versions.txt`, `genome.fasta.gz`, `genome.gtf` |
| Kallisto | `kallisto_index.idx`, `transcriptome.fasta.gz`, `kallisto_index.log`, `versions.txt`, `genome.fasta.gz`, `genome.gtf` |
| RSEM | `rsem_index/` directory, `rsem_prepare_reference.log`, `versions.txt`, `genome.fasta.gz`, optionally `genome.gtf` |

---

## 8. Configuration and Profiles

### `nextflow.config`
- Nextflow DSL2 enabled.
- Manifest: name, author (Sam Minot, Cirro Bio), version 0.1.0, requires Nextflow >= 24.04.0.
- `mainScript` is set to `main_bowtie2.nf` but each entrypoint is run explicitly.
- `test` profile: includes `tests/config/test_data.config`, sets `outdir = './results'`.

### `tests/config/nextflow.config`
Used by nf-test only. Includes root `nextflow.config` and `test_data.config`, overrides `outdir = '.nf-test'`.

### `tests/config/test_data.config`
Defines test data URLs from nf-core/test-datasets (branch: `modules`):
- `test_fasta_sarscov2`: SARS-CoV-2 genome FASTA
- `test_gtf_sarscov2`: SARS-CoV-2 genome GTF
- `test_fasta_human`: Homo sapiens genome FASTA (small subset)
- `test_gtf_human`: Homo sapiens genome GTF (small subset)

### `nf-test.config`
- `testsDir = "tests"`
- `workDir = ".nf-test"` (overridable via `NFT_WORKDIR` env var)
- `configFile = "tests/config/nextflow.config"`
- No default profile set.

---

## 9. Testing

Tests use nf-test framework. Each entrypoint has a corresponding `.nf.test` file under `tests/workflows/`.

Each test file contains two test cases:
1. **Stub test** (tagged `stub`): runs with `-stub`, no actual tool execution, fast, no Docker needed. Asserts `workflow.success`.
2. **Full test**: runs real indexing using nf-core test data pulled from GitHub. Asserts `workflow.success` and that at least one process succeeded.

### Test data used by tool

| Tool | Test genome |
|---|---|
| Bowtie2 | sarscov2 |
| STAR | homo_sapiens |
| Bismark | sarscov2 |
| BWA | sarscov2 |
| HISAT2 | sarscov2 (genome-only stub; genome + GTF for full test) |
| Salmon | sarscov2 |
| Kallisto | sarscov2 |
| RSEM | sarscov2 |

### Running tests

```bash
# Full test suite (requires nf-test and Docker/Conda)
./scripts/run_tests.sh

# Stub tests only (fast, no Docker)
nf-test test tests/workflows --tag stub

# Full tests with Docker
nf-test test tests/workflows --profile docker

# Single workflow
nf-test test tests/workflows/main_bowtie2.nf.test

# By tag
./scripts/run_tests.sh --tag bowtie2
```

---

## 10. Usage Examples

### Prerequisites
- Nextflow >= 24.04.0
- Docker or Singularity (to run tool containers), or tools installed locally
- A container image for the target tool (e.g. `quay.io/biocontainers/bowtie2:2.5.3--py39h6a678d5_0`)

### Bowtie2 (DNA alignment index)
```bash
nextflow run main_bowtie2.nf \
  --fasta genome.fa \
  --container quay.io/biocontainers/bowtie2:2.5.3--py39h6a678d5_0 \
  --outdir results/bowtie2 \
  -profile docker
```

### STAR (RNA-seq splice-aware index)
```bash
nextflow run main_star.nf \
  --fasta genome.fa \
  --gtf genes.gtf \
  --container quay.io/biocontainers/star:2.7.11b--h43eeafb_2 \
  --outdir results/star \
  -profile docker
```

### Bismark (bisulfite sequencing index)
```bash
nextflow run main_bismark.nf \
  --fasta genome.fa \
  --aligner bowtie2 \
  --container quay.io/biocontainers/bismark:0.24.0--hdfd78af_0 \
  --outdir results/bismark \
  -profile docker
```

### BWA (DNA alignment index)
```bash
nextflow run main_bwa.nf \
  --fasta genome.fa \
  --container quay.io/biocontainers/bwa:0.7.18--he4a0461_0 \
  --outdir results/bwa \
  -profile docker
```

### HISAT2 (RNA-seq index, genome only)
```bash
nextflow run main_hisat2.nf \
  --fasta genome.fa \
  --container quay.io/biocontainers/hisat2:2.2.1--h1b792b2_3 \
  --outdir results/hisat2 \
  -profile docker
```

### HISAT2 (RNA-seq index with splice sites from GTF)
```bash
nextflow run main_hisat2.nf \
  --fasta genome.fa \
  --hisat2_gtf genes.gtf \
  --container quay.io/biocontainers/hisat2:2.2.1--h1b792b2_3 \
  --outdir results/hisat2 \
  -profile docker
```

### Salmon (RNA quantification transcriptome index)
```bash
nextflow run main_salmon.nf \
  --fasta genome.fa \
  --gtf genes.gtf \
  --container quay.io/biocontainers/salmon:1.10.3--haf7b0c7_2 \
  --outdir results/salmon \
  -profile docker
```

### Kallisto (RNA quantification transcriptome index)
```bash
nextflow run main_kallisto.nf \
  --fasta genome.fa \
  --gtf genes.gtf \
  --container quay.io/biocontainers/kallisto:0.50.1--h6de1650_2 \
  --outdir results/kallisto \
  -profile docker
```

### RSEM (RNA quantification reference)
```bash
nextflow run main_rsem.nf \
  --fasta genome.fa \
  --container quay.io/biocontainers/rsem:1.3.3--pl5321hdcf5f25_4 \
  --outdir results/rsem \
  -profile docker
```

### Using the built-in test profile
```bash
# Stub run (fast, no Docker needed)
nextflow run main_bowtie2.nf -profile test -stub --container myimage --outdir results/test

# Real run with test data
nextflow run main_star.nf -profile test \
  --container quay.io/biocontainers/star:2.7.11b--h43eeafb_2 \
  --outdir results/test \
  -profile docker,test
```

---

## 11. Module Installation / Update

The `modules/` directory ships with the required module files. To update them from nf-core upstream:

```bash
pip install nf-core
./scripts/install_modules.sh
```

The script installs: `bowtie2/build`, `star/genomegenerate`, `bismark/genomepreparation`, `bwa/index`, `hisat2/build`. Note: Salmon, Kallisto, RSEM, and the shared utility modules (`gffread`, `publish_fasta`, `publish_gtf`) are custom and not installed via this script.

---

## 12. Key Relationships and Data Flow

```
Genome FASTA + optional GTF
        |
        +---> BOWTIE2_BUILD ---------> genome.bt2 index
        |
        +---> STAR_GENOMEGENERATE ----> STAR index directory
        |
        +---> BISMARK_GENOMEPREPARATION -> bisulfite genome index
        |
        +---> BWA_INDEX -------------> genome.bwt index
        |
        +---> HISAT2_BUILD (with optional splice-sites/exons/SNPs) -> genome.ht2 index
        |
        +---> GFFREAD (FASTA + GTF) -> transcriptome.fasta.gz
        |           |
        |           +---> SALMON_INDEX (+ optional extra_fasta) -> salmon_index/
        |           |
        |           +---> KALLISTO_INDEX -> kallisto_index.idx
        |
        +---> RSEM_PREPAREREFERENCE -> rsem_index/genome.*
        |
        +---> PUBLISH_FASTA ---------> genome.fasta.gz (all workflows)
        |
        +---> PUBLISH_GTF -----------> genome.gtf (when GTF provided)
```

---

## 13. Important Notes for Developers

1. **`--container` is always required** — there is no default container. The validation check in each entrypoint will exit 1 if it is not provided. Pass a Biocontainer or custom image appropriate for the tool version needed.

2. **HISAT2 `--gtf` vs `--hisat2_gtf`** — the generic `--gtf` param in `nextflow.config` only triggers `PUBLISH_GTF` (not annotation extraction) in the HISAT2 workflow. Use `--hisat2_gtf` to activate splice site/exon extraction.

3. **Salmon `extra_fasta` default** — `params.extra_fasta` defaults to `$projectDir/assets/extra.fasta`. The file in the repo is an empty placeholder. The `SALMON_INDEX` module checks if the file is >2 bytes; if the placeholder is empty, no extra sequences are concatenated.

4. **Bismark `--aligner`** — required param, must be one of the aligners Bismark supports (typically `bowtie2` or `hisat2`).

5. **Compressed inputs** — FASTA and GTF inputs can be `.gz` compressed. All modules handle decompression internally with `gzip -t ... && gzip -cd` before calling the tool.

6. **Output overwrite** — all `publishDir` directives use `overwrite: true`, so re-running to the same `--outdir` will replace existing files.

7. **Stub support** — `GFFREAD`, `PUBLISH_FASTA`, `PUBLISH_GTF`, and `SALMON_INDEX` have explicit `stub:` blocks. Other modules rely on Nextflow's default stub behavior (create empty output files matching the declared output patterns).
