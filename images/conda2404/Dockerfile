# Use the official Ubuntu 24.04 image as the base
FROM registry.cn-hangzhou.aliyuncs.com/lacogito/ubuntu:24.04

# Set environment variables for non-interactive installation
ENV DEBIAN_FRONTEND=noninteractive
ENV CONDA_DIR=/opt/conda
ENV PATH=${CONDA_DIR}/bin:${PATH}

# Update and install system dependencies
RUN apt-get update && apt-get install -y \
    wget && \
    rm -rf /var/lib/apt/lists/*

# Detect architecture and download appropriate Miniconda installer
RUN case $(uname -m) in \
        aarch64|arm64) export ARCH="aarch64" ;; \
        x86_64) export ARCH="x86_64" ;; \
        *) echo "Unsupported architecture: $(uname -m)"; exit 1 ;; \
    esac && \
    wget --quiet --no-check-certificate "https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-\${ARCH}.sh" -O miniconda.sh && \
    /bin/bash miniconda.sh -b -p $CONDA_DIR && \
    rm miniconda.sh && \
    $CONDA_DIR/bin/conda init && \
    $CONDA_DIR/bin/conda config --set auto_activate_base false

# Configure Conda to use conda-forge as the only channel
RUN conda config --remove channels defaults || true && \
    conda config --add channels conda-forge && \
    conda config --set channel_priority strict && \
    conda config --set show_channel_urls true && \
    echo "channels:" > ~/.condarc && \
    echo "  - conda-forge" >> ~/.condarc && \
    rm -f $CONDA_DIR/.condarc /etc/conda/.condarc || true
