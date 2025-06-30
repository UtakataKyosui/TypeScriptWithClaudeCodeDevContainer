# Multi-stage build to get uv
FROM ghcr.io/astral-sh/uv:latest AS uv

# Multi-stage build to get Node.js
FROM node:20-slim AS node

FROM mcr.microsoft.com/vscode/devcontainers/base:bullseye

# Copy uv and uvx from the uv image
COPY --from=uv /uv /bin/uv
COPY --from=uv /uvx /bin/uvx

# Copy Node.js from the node image with proper structure
COPY --from=node /usr/local /usr/local

# Install additional packages
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends \
        git \
        curl \
        wget \
        vim \
        jq \
        build-essential \
    && apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/*

# Install Claude CLI
RUN curl -fsSL https://claude.ai/claude-cli/install.sh | bash

# Create a non-root user
ARG USERNAME=utakata
ARG USER_UID=1100
ARG USER_GID=$USER_UID

# Create the user
RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
    && apt-get update \
    && apt-get install -y sudo \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME

# Install Node.js global packages for TypeScript development
RUN npm install -g \
    typescript \
    ts-node \
    nodemon \
    @types/node \
    eslint \
    prettier \
    @typescript-eslint/parser \
    @typescript-eslint/eslint-plugin

# Switch to the non-root user
USER $USERNAME

# Set up npm configuration for user
RUN npm config set prefix "/home/$USERNAME/.npm-global" && \
    mkdir -p "/home/$USERNAME/.npm-global/bin" && \
    mkdir -p "/home/$USERNAME/.npm-global/lib"

# Ensure npm and npx are available in PATH
ENV PATH="/home/$USERNAME/.npm-global/bin:/usr/local/bin:$PATH"
ENV NODE_PATH="/usr/local/lib/node_modules:/home/$USERNAME/.npm-global/lib/node_modules"

# Create workspace directory
RUN mkdir -p /home/$USERNAME/.anthropic

WORKDIR /workspace