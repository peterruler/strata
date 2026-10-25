# Strata

Scripts to install and run [Strata DGX Spark](https://github.com/shi3z/Strata-DGX-Spark) on an ARM64 NVIDIA GX10 / DGX Spark system.

## Requirements

- Ubuntu/Debian with `sudo` access and NVIDIA drivers (`nvidia-smi` available).
- CUDA Toolkit 13.0 (defaults to `/usr/local/cuda`).
- A writable data drive mounted at `/data`, with space for the application and models.

## Install

Run from this repository:

```bash
bash install-strata.sh
```

The installer downloads the application to `/data/ai/Strata-DGX-Spark` and stores model data in `/data/ai/Strata-data`. It configures the **coder IQ1_M** model with a **32,768-token context**, without vision, and leaves the server stopped.

To use different data or CUDA paths:

```bash
DATA_DRIVE=/mnt/data CUDA_ROOT=/usr/local/cuda-13.0 bash install-strata.sh
```

## Start

With the default installation paths:

```bash
bash run.sh
```

The server listens at **http://127.0.0.1:8080**. Press `Ctrl+C` to stop it.

For a custom data drive, start directly from the installed application:

```bash
cd /mnt/data/ai/Strata-DGX-Spark
./run-coder-iq1_m.sh
```

## Check the server

```bash
bash test.sh
```

This queries the health endpoint (`/health`) and available models (`/v1/models`).

`start.sh` combines installation and startup using the default `/data` paths. Use `run.sh` for subsequent starts.

## Available models

These are versions of **Qwen3.8-Flash-Next**. Quantization names describe compressed sizes; larger sizes generally trade speed and memory for quality.

| Version | Setup family | Sizes | Use for |
| --- | --- | --- | --- |
| Qwen3.8-Flash-Next | `qwen` | `IQ2_XS`, `IQ3_XXS`, `IQ3_S` | General chat, writing, multilingual tasks, and code. |
| Qwen3.8-Flash-Next Coder | `coder` | `IQ1_M` | Coding and coding agents; the default here. Fewer experts reduce memory use, but weaken general and multilingual answers. |
| Swift 1.5 (Flash-Next fine-tune) | `swift` | `IQ2_XS`, `IQ3_XXS` | Shorter thinking before replies. |
| Unsloth Flash-Next | `unsloth` | `UD-IQ4_XS`, `UD-Q4_K_XL` | Higher precision with larger downloads; `UD-Q4_K_XL` is experimental. |

The upstream installer also offers `qwen` / `Q2_0`, but its CPU kernel is unsupported on ARM64. The fork documents **Qwen IQ3_XXS with GPU vision** as tested on GB10; other variants are installer options, not confirmed GB10 configurations.

### Install or switch models

Stop the running server first. Use the upstream setup in the installed application:

```bash
cd /data/ai/Strata-DGX-Spark

# General-purpose Qwen
./setup.sh --setup --yes --family qwen --model IQ3_XXS \
  --context 32768 --vision no --data-dir /data/ai/Strata-data \
  --host 127.0.0.1 --port 8080 --no-browser --no-start
./run-iq3_xxs.sh
```

For other versions, replace `--family` and `--model` with a pair from the table. Setup prints the generated `run-*.sh` command. Run `./setup.sh --setup` for interactive selection. Use `--vision gpu` to enable image input on supported models.

This repository's `run.sh` always starts Coder; use the generated launcher for other models.

## Usage

- **Browser chat:** open [localhost:8080](http://127.0.0.1:8080).
- **Apps and coding agents:** select an OpenAI-compatible provider with base URL `http://127.0.0.1:8080/v1`. Use the model ID from `/v1/models`; the default local setup accepts any API key.
- **Reasoning:** choose a lower thinking level for quicker replies or a higher level for harder tasks in the chat settings.

See the upstream [model guide](https://github.com/shi3z/Strata-DGX-Spark/blob/main/docs/MODELS.md) and [GB10 notes](https://github.com/shi3z/Strata-DGX-Spark#strata-on-the-nvidia-dgx-spark-gb10-arm64) for details.
