FROM node:24-slim

ARG TZ
ARG USERNAME=codex
ARG USER_UID=1000
ARG USER_GID=1000

ENV TZ="$TZ"

# Install tools, ca-certificates, then clean up apt cache to reduce image size
RUN apt-get update && apt-get install -y --no-install-recommends \
  aggregate \
  ca-certificates \
  curl \
  dnsutils \
  socat \
  fzf \
  gh \
  git \
  gnupg2 \
  iproute2 \
  iptables \
  tcpdump \
  net-tools \
  netcat-openbsd \
  gosu \
  jq \
  less \
  man-db \
  procps \
  unzip \
  ripgrep \
  zsh \
  && rm -rf /var/lib/apt/lists/*

# Ensure default node user has access to /usr/local/share
RUN mkdir -p /usr/local/share/npm-global && \
  chown -R node:node /usr/local/share

# Ensure login shells keep npm global binaries on PATH
RUN echo 'export PATH="/usr/local/share/npm-global/bin:$PATH"' > /etc/profile.d/npm-global.sh

ARG USERNAME=node

# Set up non-root user
USER node

# Install global packages
ENV NPM_CONFIG_PREFIX=/usr/local/share/npm-global
ENV PATH=$PATH:/usr/local/share/npm-global/bin

RUN npm install -g @openai/codex

# Inside the container we consider the environment already sufficiently locked
# down, therefore instruct Codex CLI to allow running without sandboxing.
ENV CODEX_UNSAFE_ALLOW_NO_SANDBOX=1

# Codex callback server hack, see README.md
USER root
COPY scripts/codex-login-hack.sh /usr/local/bin/
RUN chmod 500 /usr/local/bin/codex-login-hack.sh

# Codex OAuth callback HTTP port
EXPOSE 1455
# MCP Streamable HTTP port
EXPOSE 7000

USER node
WORKDIR /home/node/

# https://github.com/supercorp-ai/supergateway
# stdio → Streamable HTTP
CMD [ "npx", "-y", "supergateway", "--stdio", "codex mcp", "--outputTransport", "streamableHttp", "--port", "7000" ]
