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
RUN git clone --depth=1 --branch for_devc https://github.com/caesar0301/dotfiles.git ~/.dotfiles
RUN cd ~/.dotfiles && ./zsh/install.sh
RUN cd ~/.dotfiles && SUDO_PASS="${SUDO_PASS}" ~/.dotfiles/nvim/install.sh

# Set the default command to start a bash shell
CMD ["/usr/bin/zsh"]
