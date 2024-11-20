# Pulsar Analysis Tools Docker Environment

This Docker environment provides a ready-to-use setup for pulsar data analysis, including the following tools:
- PSRCHIVE: A suite of tools for analyzing pulsar astronomical data
- DSPSR: A flexible digital signal processing software for pulsar astronomy
- PSRXML: A tool for handling pulsar data in XML format
- PSRSALSA: A suite of tools for pulsar analysis focused on single-pulse studies
- Julia: A high-level programming language for numerical analysis and scientific computing

## Building the Docker Image

To build the Docker image, run the following command in this directory:

```bash
docker build -t pulsar-tools .
```

## Running the Container

To run the container with a mounted working directory:

```bash
docker run -it -v $(pwd):/work pulsar-tools
```

This will mount your current directory to the `/work` directory inside the container.

## Available Tools

Once inside the container, you can use the following tools:
- PSRCHIVE suite of commands (e.g., `psrsh`, `pdv`, `paz`, etc.)
- DSPSR commands
- PSRXML tools
- PSRSALSA commands (e.g., `pspec`, `SNRcount`, etc.)
- Julia programming language (command: `julia`)

## Environment Variables

The following environment variables are pre-configured:
- `LD_LIBRARY_PATH`: Set to include `/usr/local/lib`
- `PGPLOT_DIR`: Set to `/usr/lib/pgplot5`
- `PGPLOT_FONT`: Set to `/usr/lib/pgplot5/grfont.dat`
- `PATH`: Updated to include PSRSALSA binaries
