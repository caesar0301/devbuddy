# Base image of devcontainer, xiaming chen
# Use the official Ubuntu 24.04 image as the base image
FROM ubuntu:24.04

# Replace sources.list with the Aliyun mirror
RUN sed -i 's|http://ports.ubuntu.com/ubuntu-ports|http://mirrors.aliyun.com/ubuntu-ports|g' /etc/apt/sources.list.d/ubuntu.sources

# Update package list and install sudo, then clean up to reduce image size
RUN apt-get update && apt-get install -y sudo adduser \
      build-essential git curl wget vim nano \
      cmake gdb llvm clang zsh tmux python3 python3-pip \
      openjdk-17-jdk openjdk-21-jdk nodejs npm \
      universal-ctags ripgrep silversearcher-ag \
      iputils-ping netcat-openbsd bsdmainutils \
      libbz2-dev libreadline-dev libsqlite3-dev \
      liblzma-dev \
    && apt-get clean && rm -rf /var/lib/apt/lists/*
