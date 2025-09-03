# Use the official Ubuntu 22.04 image as the base
FROM registry.cn-hangzhou.aliyuncs.com/lacogito/ubuntu:22.04

# Set environment variables for non-interactive installation
ENV DEBIAN_FRONTEND=noninteractive

# Update and install system dependencies                                                                                                                                                                               [0/3021]
RUN apt-get update && apt-get install -y \
    wget \
    git \
    build-essential \
    libsm6 \
    libxext6 \
    libxrender-dev \
    libblas-dev \
    liblapack-dev && \
    rm -rf /var/lib/apt/lists/*

# Add NVIDIA package repositories for Ubuntu 22.04
RUN wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/cuda-ubuntu2204.pin && \
    mv cuda-ubuntu2204.pin /etc/apt/preferences.d/cuda-repository-pin-600 && \
    wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/cuda-keyring_1.1-1_all.deb && \
    dpkg -i cuda-keyring_1.1-1_all.deb

# Update and install system dependencies
RUN apt-get update && apt-get install -y \
    cuda-toolkit && \
    rm -rf /var/lib/apt/lists/*

# Set up the CUDA environment
ENV CUDA_HOME=/usr/local/cuda
ENV PATH=$CUDA_HOME/bin:$PATH

# Install Miniconda
RUN wget --no-check-certificate https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O miniconda.sh && \
    chmod +x miniconda.sh && \
    ./miniconda.sh -b -p /opt/conda && \
    rm miniconda.sh

# Set up the Conda environment
ENV PATH="/opt/conda/bin:${PATH}"
RUN conda init bash

# Accept Conda's Terms of Service for non-interactive use
RUN conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/main && \
    conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/r

# Create a Conda environment for sglang
RUN conda create -n sglang_env python=3.10 -y
SHELL ["conda", "run", "-n", "sglang_env", "/bin/bash", "-c"]

ENV PYTHONUNBUFFERED=1 PYTHONIOENCODING=utf-8 LANG=C.UTF-8 PIP_INDEX_URL=https://mirrors.aliyun.com/pypi/simple/

# Install PyTorch and a compatible version of torchvision
RUN pip install torch==2.5.1+cu124 torchvision==0.20.1+cu124 torchaudio==2.5.1+cu124 --index-url https://download.pytorch.org/whl/cu124

# Now, install the remaining libraries
RUN pip install -U \
    sglang \
    "transformers>=4.40.1" \
    "diffusers>=0.28.0" \
    "peft>=0.10.0" \
    "accelerate>=0.29.0" \
    "bitsandbytes>=0.43.1" \
    "flash-attn>=2.5.8" \
    "ninja" \
    "sentencepiece" \
    "protobuf" \
    "Pillow"
