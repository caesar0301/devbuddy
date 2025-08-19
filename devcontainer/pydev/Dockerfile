# Base image of devcontainer, xiaming chen
# Use the official Ubuntu 24.04 image as the base image
FROM registry.cn-hangzhou.aliyuncs.com/lacogito/devcontainer:ubuntu2404-base

# Create a new user named 'admin' and add it to the sudo group
ARG SUDO_PASS=devadmin
RUN adduser --disabled-password --gecos "" admin && \
    echo "admin:${SUDO_PASS}" | chpasswd && \
    usermod -aG sudo admin && \
    chsh -s /usr/bin/zsh admin

# Switch to the 'admin' user
USER admin
WORKDIR /home/admin

# Install dotfiles
RUN git clone --depth=1 https://github.com/caesar0301/dotfiles.git ~/.dotfiles

RUN mkdir -p ~/.config
RUN cd ~/.dotfiles && ./zsh/install.sh
RUN cd ~/.dotfiles && ~/.dotfiles/nvim/install.sh

RUN /usr/bin/zsh && \
    export PYENV_ROOT="$HOME/.pyenv" && \
    [ -d $PYENV_ROOT/bin ] && \
    export PATH="$PYENV_ROOT/bin:$PATH" && \
    pyenv install 3.7.15 && \
    pyenv install 3.8.20 && \
    pyenv install 3.9.20 && \
    pyenv install 3.10.15 && \
    pyenv install 3.11.10 && \
    pyenv install 3.12.9

# Set the default command to start a bash shell
CMD ["/usr/bin/zsh"]
