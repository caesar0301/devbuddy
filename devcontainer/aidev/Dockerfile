# AI Development Environment with GPU Support
FROM ubuntu:24.04

# Replace sources.list with the Aliyun mirror
RUN sed -i 's|http://ports.ubuntu.com/ubuntu-ports|http://mirrors.aliyun.com/ubuntu-ports|g' /etc/apt/sources.list.d/ubuntu.sources

# Update package list and install basic tools
RUN apt-get update && apt-get install -y sudo adduser \
      build-essential git curl wget vim nano \
      cmake gdb llvm clang zsh tmux \
      openjdk-17-jdk openjdk-21-jdk nodejs npm \
      universal-ctags ripgrep silversearcher-ag \
      iputils-ping netcat-openbsd bsdmainutils \
      libbz2-dev libreadline-dev libsqlite3-dev \
      liblzma-dev software-properties-common \
      ca-certificates gnupg lsb-release \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install Python 3.12
RUN add-apt-repository ppa:deadsnakes/ppa -y && \
    apt-get update && \
    apt-get install -y python3.12 python3.12-dev python3.12-venv python3.12-distutils && \
    curl -sS https://bootstrap.pypa.io/get-pip.py | python3.12 && \
    update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.12 1 && \
    update-alternatives --install /usr/bin/python python /usr/bin/python3.12 1 && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Install NVIDIA Container Toolkit prerequisites
RUN apt-get update && \
    apt-get install -y gpg-agent && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Install CUDA keyring and CUDA toolkit
RUN wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2404/x86_64/cuda-keyring_1.1-1_all.deb && \
    dpkg -i cuda-keyring_1.1-1_all.deb && \
    apt-get update && \
    apt-get install -y cuda-toolkit-12-6 && \
    rm cuda-keyring_1.1-1_all.deb && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Install cuDNN
RUN apt-get update && \
    apt-get install -y libcudnn9-dev && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Install AI/ML Python packages
RUN python3.12 -m pip install --no-cache-dir --upgrade pip setuptools wheel && \
    python3.12 -m pip install --no-cache-dir \
    torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121 \
    tensorflow[and-cuda] \
    numpy pandas scikit-learn matplotlib seaborn \
    jupyter jupyterlab notebook \
    transformers accelerate datasets \
    opencv-python pillow \
    wandb tensorboard \
    pytest black flake8 isort mypy \
    fastapi uvicorn \
    gradio streamlit \
    langchain openai anthropic

# Create a non-root user
RUN useradd -m -s /bin/zsh vscode && \
    echo "vscode ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Set up zsh as default shell for vscode user
USER vscode
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

# Set environment variables
ENV CUDA_HOME=/usr/local/cuda
ENV PATH=${CUDA_HOME}/bin:${PATH}
ENV LD_LIBRARY_PATH=${CUDA_HOME}/lib64:${LD_LIBRARY_PATH}
ENV PYTHONPATH=/workspace:${PYTHONPATH}

# Switch back to root for final setup
USER root

# Set working directory
WORKDIR /workspace

# Default command
CMD ["/bin/zsh"]