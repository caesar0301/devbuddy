# Use the official Ubuntu 24.04 image as the base
FROM registry.cn-hangzhou.aliyuncs.com/lacogito/ubuntu:24.04

# Set environment variables for non-interactive installation
ENV DEBIAN_FRONTEND=noninteractive

# Update and install system dependencies
RUN apt-get update && apt-get install -y \
    wget && \
    rm -rf /var/lib/apt/lists/*

# Install Miniconda adaptively for x86_64 or aarch64
RUN ARCH=$(uname -m) && \
    if [ "$ARCH" = "x86_64" ]; then \
        MINICONDA_URL="https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh"; \
    elif [ "$ARCH" = "aarch64" ]; then \
        MINICONDA_URL="https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-aarch64.sh"; \
    else \
        echo "Unsupported architecture: $ARCH"; exit 1; \
    fi && \
    wget --no-check-certificate --quiet "$MINICONDA_URL" -O /tmp/miniconda.sh && \
    /bin/bash /tmp/miniconda.sh -b -p /opt/conda && \
    rm /tmp/miniconda.sh && \
    /opt/conda/bin/conda init && \
    /opt/conda/bin/conda config --set auto_activate_base false

# Set up the Conda environment
ENV PATH="/opt/conda/bin:${PATH}"

# Configure Conda to use conda-forge as the only channel
RUN conda config --remove channels defaults || true && \
    conda config --add channels conda-forge && \
    conda config --set channel_priority strict && \
    conda config --set show_channel_urls true && \
    echo "channels:" > ~/.condarc && \
    echo "  - conda-forge" >> ~/.condarc && \
    rm -f /opt/conda/.condarc /etc/conda/.condarc || true
