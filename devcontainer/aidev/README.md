# AI Development Environment DevContainer

A comprehensive development environment for AI/ML projects with GPU support, Python 3.12, and pre-configured dotfiles.

## Features

### 🚀 Core Components
- **Base Image**: Ubuntu 24.04 LTS
- **Python**: 3.12 with pip, venv, and distutils
- **GPU Support**: CUDA 12.6 toolkit and cuDNN 9
- **Shell**: Zsh with Oh My Zsh configuration
- **Editor**: Vim with AI-friendly configuration

### 🧠 AI/ML Stack
- **PyTorch**: Latest version with CUDA support
- **TensorFlow**: Latest version with CUDA support
- **Transformers**: Hugging Face transformers library
- **Jupyter**: Lab and Notebook with pre-configured settings
- **Data Science**: NumPy, Pandas, Scikit-learn, Matplotlib, Seaborn
- **Computer Vision**: OpenCV, Pillow
- **MLOps**: Weights & Biases, TensorBoard
- **APIs**: FastAPI, Gradio, Streamlit
- **LLM**: LangChain, OpenAI, Anthropic clients

### 🛠️ Development Tools
- **Code Quality**: Black, Flake8, isort, mypy
- **Testing**: pytest
- **Version Control**: Git with GitHub CLI
- **Container**: Docker-in-Docker support
- **Languages**: Java (17, 21), Node.js, npm
- **Build Tools**: CMake, Make, GCC, Clang
- **Text Processing**: ripgrep, ag, universal-ctags

### 📦 VS Code Extensions
- Python development (Python, Pylance, Debugpy)
- Jupyter notebooks
- GitHub Copilot and Copilot Chat
- C/C++ development
- YAML/JSON support
- Makefile support

## Usage

### Building the Container

1. **Open in VS Code**: Open the workspace in VS Code
2. **Reopen in Container**: Use Command Palette (`Ctrl+Shift+P`) and select "Dev Containers: Reopen in Container"
3. **Select Configuration**: Choose the "AI Development Environment" configuration

### GPU Requirements

The container is configured to use all available GPUs. Requirements:
- NVIDIA GPU with CUDA capability
- NVIDIA Docker runtime installed on host
- GPU drivers installed on host system

### Dotfiles Support

The container automatically looks for dotfiles in these locations:
- `/workspace/.dotfiles`
- `/workspace/dotfiles`

If found, it will:
1. Create a symlink to `~/.dotfiles`
2. Look for and run installation scripts:
   - `install.sh`
   - `setup.sh`
   - `Makefile` (runs `make install`)
3. Manually symlink common files if no install script found

If no dotfiles repository is found, it creates basic configurations for:
- `.zshrc` with AI-specific aliases and functions
- `.gitconfig` with sensible defaults
- `.vimrc` with Python-friendly settings
- Jupyter configuration

### Quick Start Commands

```bash
# Test GPU availability
gpu-test

# Check GPU status
gpu

# Start Jupyter Lab
jlab

# Start Jupyter Notebook
jnb

# Python development
python --version  # Should show Python 3.12.x
pip list          # Show installed packages
```

### Useful Aliases

- `python` → `python3.12`
- `pip` → `python3.12 -m pip`
- `gpu` → `nvidia-smi`
- `jlab` → `jupyter lab --ip=0.0.0.0 --port=8888 --no-browser --allow-root`
- `jnb` → `jupyter notebook --ip=0.0.0.0 --port=8888 --no-browser --allow-root`

### Environment Variables

- `CUDA_HOME=/usr/local/cuda`
- `PATH` includes CUDA binaries
- `LD_LIBRARY_PATH` includes CUDA libraries
- `PYTHONPATH` includes workspace directory

## Customization

### Adding Python Packages

Edit the Dockerfile to add packages during build:

```dockerfile
RUN python3.12 -m pip install --no-cache-dir your-package
```

Or install them after container creation:

```bash
pip install your-package
```

### Adding System Packages

Edit the Dockerfile to add system packages:

```dockerfile
RUN apt-get update && apt-get install -y your-package
```

### Customizing Dotfiles

Place your dotfiles repository in `/workspace/.dotfiles` or `/workspace/dotfiles` and they will be automatically installed.

## Troubleshooting

### GPU Not Available

1. Verify GPU on host: `nvidia-smi`
2. Check Docker GPU support: `docker run --rm --gpus all nvidia/cuda:12.6-runtime-ubuntu24.04 nvidia-smi`
3. Ensure devcontainer has `"runArgs": ["--gpus=all"]`

### Python Package Issues

1. Ensure you're using the correct Python version: `python --version`
2. Check if package supports CUDA: `python -c "import torch; print(torch.cuda.is_available())"`
3. Reinstall with CUDA support if needed

### Jupyter Access

Jupyter is configured to run on `0.0.0.0:8888` without authentication. Access via:
- `http://localhost:8888` (if port forwarding is set up)
- Use VS Code's port forwarding feature

## Files Structure

```
devcontainer/aidev/
├── devcontainer.json     # Main devcontainer configuration
├── Dockerfile           # Container build instructions
├── setup-dotfiles.sh    # Post-creation dotfiles setup
└── README.md           # This file
```

## Contributing

To improve this environment:
1. Test changes thoroughly
2. Update documentation
3. Consider backward compatibility
4. Submit pull requests with clear descriptions