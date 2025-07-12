# AI Development devcontainer, xiaming chen
# Use the base devcontainer image
FROM registry.cn-hangzhou.aliyuncs.com/lacogito/devcontainer:ubuntu2404-base

# Create a new user named 'admin' and add it to the sudo group
ARG SUDO_PASS=devadmin
RUN adduser --disabled-password --gecos "" admin && \
    echo "admin:${SUDO_PASS}" | chpasswd && \
    usermod -aG sudo admin && \
    usermod -aG video admin && \
    chsh -s /usr/bin/zsh admin

# Install GPU drivers and CUDA dependencies
RUN apt-get update && apt-get install -y \
    nvidia-driver-535 \
    nvidia-cuda-toolkit \
    nvidia-container-toolkit \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install additional AI/ML dependencies
RUN apt-get update && apt-get install -y \
    libblas-dev liblapack-dev libatlas-base-dev \
    libhdf5-dev libhdf5-serial-dev \
    libjpeg-dev libpng-dev libtiff-dev \
    libavcodec-dev libavformat-dev libswscale-dev \
    libv4l-dev libxvidcore-dev libx264-dev \
    libgtk-3-dev libcanberra-gtk3-dev \
    libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev \
    libgstreamer-plugins-bad1.0-dev gstreamer1.0-plugins-base \
    gstreamer1.0-plugins-good gstreamer1.0-plugins-bad \
    gstreamer1.0-plugins-ugly gstreamer1.0-libav \
    gstreamer1.0-tools gstreamer1.0-x gstreamer1.0-alsa \
    gstreamer1.0-gl gstreamer1.0-gtk3 gstreamer1.0-qt5 \
    gstreamer1.0-pulseaudio \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Switch to the 'admin' user
USER admin
WORKDIR /home/admin

# Install dotfiles
RUN git clone --depth=1 --branch for_devc https://github.com/caesar0301/dotfiles.git ~/.dotfiles

RUN mkdir -p ~/.config
RUN cd ~/.dotfiles && ./zsh/install.sh
RUN cd ~/.dotfiles && SUDO_PASS="${SUDO_PASS}" ~/.dotfiles/nvim/install.sh

# Install Python 3.12 and pyenv
RUN /usr/bin/zsh && \
    export PYENV_ROOT="$HOME/.pyenv" && \
    [ -d $PYENV_ROOT/bin ] && \
    export PATH="$PYENV_ROOT/bin:$PATH" && \
    pyenv install 3.12.9 && \
    pyenv global 3.12.9 && \
    pip install --upgrade pip

# Install common AI/ML Python packages
RUN /usr/bin/zsh && \
    export PYENV_ROOT="$HOME/.pyenv" && \
    export PATH="$PYENV_ROOT/bin:$PATH" && \
    pyenv global 3.12.9 && \
    pip install \
    numpy pandas matplotlib seaborn \
    scikit-learn scipy jupyter \
    torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118 \
    tensorflow tensorflow-gpu \
    transformers datasets accelerate \
    opencv-python pillow \
    plotly bokeh \
    streamlit gradio \
    fastapi uvicorn \
    pytest black flake8 mypy \
    ipython jupyterlab

# Set environment variables for GPU support
ENV NVIDIA_VISIBLE_DEVICES=all
ENV NVIDIA_DRIVER_CAPABILITIES=compute,utility

# Set the default command to start a zsh shell
CMD ["/usr/bin/zsh"]