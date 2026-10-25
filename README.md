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
