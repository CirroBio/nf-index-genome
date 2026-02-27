# nf-index-genome

Utilities for building genome indices using [nf-core/modules](https://github.com/nf-core/modules). Each tool has its own Nextflow entrypoint that runs the corresponding nf-core index module.

## Tools

| Tool      | Entrypoint         | Description |
|-----------|--------------------|-------------|
| **Bowtie2** | `main_bowtie2.nf`  | Bowtie2 genome index (`.bt2`) |
| **STAR**    | `main_star.nf`     | STAR genome index (splice-aware with GTF) |
| **STAR 2**  | `main_star2.nf`    | Alias for STAR 2.x (same as `main_star.nf`) |
| **Bismark** | `main_bismark.nf`  | Bismark bisulfite genome preparation |
| **BWA**     | `main_bwa.nf`      | BWA genome index |
| **HISAT2**  | `main_hisat2.nf`   | HISAT2 genome index (optional GTF/splice sites for RNA) |

## Setup

1. **Install Nextflow** (>= 24.04.0).

2. **Modules**: This repo ships with the required nf-core modules under `modules/nf-core/modules/`, so you can run the workflows as-is. To update modules from nf-core (optional):

   ```bash
   pip install nf-core  # or conda install nf-core
   ./scripts/install_modules.sh
   ```

## Usage

Common options (all workflows):

- `--fasta` – (required) Path to reference genome FASTA.
- `--outdir` – Output directory (default: `./results`).
- `--gtf` – (required for STAR/STAR2; optional for HISAT2) Gene annotation GTF.
- `--splicesites` – (optional, HISAT2 only) Splice sites file.

### Examples

```bash
# Bowtie2 index
nextflow run main_bowtie2.nf --fasta genome.fa --outdir results/bowtie2

# STAR index (GTF required for splice-aware index)
nextflow run main_star.nf --fasta genome.fa --gtf genes.gtf --outdir results/star

# STAR 2 (same as above)
nextflow run main_star2.nf --fasta genome.fa --gtf genes.gtf --outdir results/star2

# Bismark genome preparation
nextflow run main_bismark.nf --fasta genome.fa --outdir results/bismark

# BWA index
nextflow run main_bwa.nf --fasta genome.fa --outdir results/bwa

# HISAT2 (genome-only or with GTF/splice sites)
nextflow run main_hisat2.nf --fasta genome.fa --outdir results/hisat2
nextflow run main_hisat2.nf --fasta genome.fa --gtf genes.gtf --splicesites ss.txt --outdir results/hisat2
```

Run with Docker or Singularity so the nf-core module containers are used:

```bash
nextflow run main_bowtie2.nf --fasta genome.fa -profile docker
nextflow run main_star.nf --fasta genome.fa --gtf genes.gtf -profile singularity
```

## Testing

Tests use the same input files as [nf-core/modules](https://github.com/nf-core/modules) (from [nf-core/test-datasets](https://github.com/nf-core/test-datasets), branch `modules`), pulled via HTTP at runtime.

**Run the test suite (requires [nf-test](https://www.nf-test.com/)):**

```bash
nextflow plugin add nf-test   # one-time
./scripts/run_tests.sh
```

Run only stub tests (no real indexing, fast; no Docker needed):

```bash
nf-test test tests/workflows --tag stub
```

Full tests (real indexing) require Docker or Conda so the tools are available:

```bash
nf-test test tests/workflows --profile docker
```

Run a single workflow’s tests:

```bash
nf-test test tests/workflows/main_bowtie2.nf.test
```

**Quick run with Nextflow (no nf-test):** use the `test` profile so `--fasta` and `--gtf` point at nf-core test data:

```bash
nextflow run main_bowtie2.nf -profile test -stub --outdir results/test
```

Test data URLs are defined in `tests/config/test_data.config`.

## Project structure

- `main_<tool>.nf` – Entrypoints; each defines a workflow that calls the matching nf-core module.
- `workflows/<tool>.nf` – Workflow definitions that include and run the nf-core module.
- `modules/nf-core/modules/` – nf-core modules (created by `install_modules.sh`).
- `tests/config/` – Test config and nf-core test data URLs.
- `tests/workflows/` – nf-test workflow tests (one `*.nf.test` per entrypoint).
- `conf/base.config` – Process defaults (CPU, memory, time).

## License

See the nf-core module licenses (Bowtie2: GPL-3.0, STAR: MIT, Bismark: GPL-3.0, etc.).
