FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ARG USERNAME=devuser
ARG USER_UID=1000
ARG USER_GID=${USER_UID}

RUN apt update && apt install -y sudo procps net-tools git curl vim jq unzip gnupg2 ca-certificates build-essential xz-utils wget && \
    apt clean && rm -rf /var/lib/apt/lists/*

# Create a non-root user for devcontainer sessions.
RUN if getent group "${USER_GID}" >/dev/null; then \
        GROUP_NAME="$(getent group "${USER_GID}" | cut -d: -f1)"; \
    else \
        GROUP_NAME="${USERNAME}"; \
        groupadd --gid "${USER_GID}" "${GROUP_NAME}"; \
    fi \
    && if ! id -u "${USERNAME}" >/dev/null 2>&1; then \
        if getent passwd "${USER_UID}" >/dev/null; then \
            useradd --gid "${GROUP_NAME}" -m -s /bin/bash "${USERNAME}"; \
        else \
            useradd --uid "${USER_UID}" --gid "${GROUP_NAME}" -m -s /bin/bash "${USERNAME}"; \
        fi; \
    fi \
    && usermod -aG sudo "${USERNAME}" \
    && echo "${USERNAME} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/${USERNAME} \
    && echo "%sudo ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/99-sudo-nopasswd \
    && chmod 0440 /etc/sudoers.d/${USERNAME} /etc/sudoers.d/99-sudo-nopasswd

# Ensure workspace path exists even before bind mounts are attached.
RUN install -d -m 0755 "/home/${USERNAME}" "/home/${USERNAME}/workspace" \
    && chown -R "${USERNAME}:${USER_GID}" "/home/${USERNAME}"

# Install Docker CLI for controlling the host Docker socket from the devcontainer.
RUN install -d -m 0755 /etc/apt/keyrings \
    && curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc \
    && chmod a+r /etc/apt/keyrings/docker.asc \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu noble stable" > /etc/apt/sources.list.d/docker.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends docker-ce-cli docker-compose-plugin \
    && rm -rf /var/lib/apt/lists/*

# Install kubectl.
RUN curl -fsSL "https://pkgs.k8s.io/core:/stable:/v1.30/deb/Release.key" | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg \
    && chmod 0644 /etc/apt/keyrings/kubernetes-apt-keyring.gpg \
    && echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /" > /etc/apt/sources.list.d/kubernetes.list \
    && chmod 0644 /etc/apt/sources.list.d/kubernetes.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends kubectl \
    && rm -rf /var/lib/apt/lists/*

# Install GitHub CLI.
RUN mkdir -p -m 755 /etc/apt/keyrings \
    && wget -qO- https://cli.github.com/packages/githubcli-archive-keyring.gpg | dd of=/etc/apt/keyrings/githubcli-archive-keyring.gpg \
    && chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" > /etc/apt/sources.list.d/github-cli.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends gh \
    && rm -rf /var/lib/apt/lists/*
