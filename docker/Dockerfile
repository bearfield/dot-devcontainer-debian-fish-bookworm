FROM debian:bookworm-slim
#
# set argument
# Default values for build arguments (can be overridden during build)
ARG USER_NAME=devuser
ARG USER_ID=1000
ARG GROUP_ID=$USER_ID
#
# install packages and tools
ENV DEBIAN_FRONTEND=noninteractive
#
# create noroot user
RUN mkdir -p /etc/sudoers.d \
    && groupadd --gid ${GROUP_ID} ${USER_NAME} \
    && useradd -s "/usr/bin/fish" --uid ${USER_ID} --gid ${GROUP_ID} -m ${USER_NAME} \
    && echo "${USER_NAME} ALL=(root) NOPASSWD:ALL" > /etc/sudoers.d/${USER_NAME} \
    && chmod 0440 /etc/sudoers.d/${USER_NAME}
RUN apt-get update \
    # install debian packages
    && apt-get install  --no-install-recommends -y \
        ca-certificates \
        git \
        lsb-release \
        sudo \
        curl \
        gnupg \
        make \
        peco \
        fish \
        locales \
        openssh-client \
        unzip \
        wget \
        shellcheck \
        libcurl4-gnutls-dev \
        libexpat1-dev gettext \
        libz-dev \
        libssl-dev \
        gcc \
        less \
        jq \
        ripgrep \
        tree \
        zip \
        unzip \
        python3 \
        python3-dev \
        build-essential \
        libffi-dev \
#
# set locale
    && echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen \
    && locale-gen \
    && update-locale LANG=en_US.UTF-8 \
    && update-locale LC_CTYPE=en_US.UTF-8 \
#
# install powerline patched fonts
    && apt-get install -y \
        fonts-powerline \
    # crean up
    && apt-get autoremove -y \
    && apt-get clean -y \
	&& rm -rf /var/lib/apt/lists/*
# install Google Cloud SDK
RUN echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list \
    && curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg \
    && apt-get update -y \
    && apt-get install -y \
        google-cloud-sdk \
        kubectl \
        google-cloud-cli-gke-gcloud-auth-plugin \
    # crean up
    && apt-get clean -y \
	&& rm -rf /var/lib/apt/lists/*
# install GitHub CLI
RUN mkdir -p -m 755 /etc/apt/keyrings \
    && wget -qO- https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null \
    && chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
    && apt-get update \
    && apt-get install -y gh \
    # clean up
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*
# install AWS CLI
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
    && unzip awscliv2.zip \
    && sudo ./aws/install
#
# install docker
    # Add Docker's official GPG key:
RUN install -m 0755 -d /etc/apt/keyrings \
    && curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc \
    && chmod a+r /etc/apt/keyrings/docker.asc \
    # Add the repository to Apt sources:
    && echo \
        "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
        $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
        tee /etc/apt/sources.list.d/docker.list > /dev/null \
    && apt-get update \
    # Install the Docker packages.
    && apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin \
    && usermod -aG docker $USER_NAME \
    # crean up
    && apt-get autoremove -y \
    && apt-get clean -y \
	&& rm -rf /var/lib/apt/lists/*
# install Node.js (needed for claude-code)
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs \
    && npm install -g npm@latest \
    # crean up
    && apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*
# install uv globally
RUN curl -LsSf https://astral.sh/uv/install.sh | sh \
    && mv /root/.local/bin/uv /usr/local/bin/uv \
    && chmod 755 /usr/local/bin/uv \
    && rm -rf /root/.local
# Install Python system-wide
RUN export UV_PYTHON_INSTALL_DIR=/opt/uv/python \
    && uv python install 3.13 \
    && uv python pin 3.13 \
    && ln -sf /opt/uv/python/cpython-3.13.*/bin/python3.13 /usr/local/bin/python3.13 \
    && ln -sf /usr/local/bin/python3.13 /usr/local/bin/python3 \
    && ln -sf /usr/local/bin/python3.13 /usr/local/bin/python \
    && chmod -R 755 /opt/uv
# Install Python tools as devuser
USER $USER_NAME
RUN uv tool install httpie \
    && uv tool install yq \
    && uv tool install ruff \
    && uv tool install mypy \
    && uv tool install black \
    && uv tool install pytest \
    && uv tool install ipython \
    && uv tool install poetry \
    && uv tool install pipx
# Switch back to root
USER root
#
# isntall fisher
USER $USER_NAME
SHELL ["fish", "-c"]
RUN curl -sL https://git.io/fisher | source && fisher install jorgebucaran/fisher
# insetall my fish plugin
RUN fisher install bearfield/peco_select_gce_ssh
RUN fisher install bearfield/peco_select_gcp_project
# power line style
RUN fisher install oh-my-fish/theme-bobthefish
# install claude-code as user
RUN mkdir -p /home/$USER_NAME/.npm-global && \
    npm config set prefix /home/$USER_NAME/.npm-global && \
    npm install -g @anthropic-ai/claude-code && \
    npm install -g @openai/codex
# copy config.fish
COPY config.fish /home/$USER_NAME/.config/fish/config.fish

# create .claude directory for Claude Code settings
RUN mkdir -p /home/$USER_NAME/.claude && \
    chown -R $USER_NAME:$USER_NAME /home/$USER_NAME/.claude && \
    chmod 755 /home/$USER_NAME/.claude

# create .codex directory for Codex CLI settings and runtime files
RUN mkdir -p /home/$USER_NAME/.codex && \
    chown -R $USER_NAME:$USER_NAME /home/$USER_NAME/.codex && \
    chmod 755 /home/$USER_NAME/.codex

# set env
ENV DEBIAN_FRONTEND=dialog
# Add npm global bin to PATH for user
ENV PATH="/home/$USER_NAME/.npm-global/bin:$PATH"
# Python environment variables
ENV PYTHONUNBUFFERED=1
ENV PYTHONDONTWRITEBYTECODE=1
ENV UV_SYSTEM_PYTHON=1
LABEL org.opencontainers.image.source=https://github.com/bearfield/dot-devcontainer-debian-fish-bookworm
