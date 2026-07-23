FROM  python:3.10-slim-bookworm AS base

# Environment
ENV PYTHONUNBUFFERED=1
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8

SHELL ["/bin/bash", "-xo", "pipefail", "-c"]

# Other requirements and recommendations
# See https://github.com/odoo/odoo/blob/17.0/debian/control
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    adduser \
    build-essential \
    fonts-liberation2 \
    gsfonts \
    locales-all \
    gettext \
    git \
    nano \
    vim \
    openssh-client \
    ca-certificates \
    gnupg \
    curl \
    wget \
    python3-dev \
    libxml2-dev \
    libxslt1-dev \
    zlib1g-dev \
    libsasl2-dev \
    libldap2-dev \
    libssl-dev \
    libffi-dev \
    libjpeg-dev \
    libpq-dev \
    liblcms2-dev \
    libblas-dev \
    libatlas-base-dev \
    zsh \
    lsb-release \
    rsync \
    chromium \
    fonts-liberation \
    && apt-get autoremove -yqq \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js 20 (LTS).
# El paquete `npm` de Debian arrastra Node 18, pero @playwright/mcp exige
# Node >=20. Instalamos Node 20 desde NodeSource (trae node + npm 10).
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y --no-install-recommends nodejs \
    && rm -rf /var/lib/apt/lists/*

# rtlcss (genera CSS RTL de los assets de Odoo)
# + Playwright MCP: da a Claude herramientas de navegador (navegar el Odoo vivo,
#   login, clic, scroll, screenshots, inspección de layout/overflow). Reutiliza el
#   chromium del sistema (/usr/bin/chromium) vía --executable-path en /workspace/.mcp.json,
#   por eso NO descargamos el navegador propio de Playwright (PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD).
ENV PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=1
RUN npm install -g rtlcss @playwright/mcp@latest

# Install wkhtmltopdf
ARG TARGETARCH
ARG WKHTMLTOPDF_VERSION=0.12.6.1
ARG WKHTMLTOPDF_AMD64_CHECKSUM="98ba0d157b50d36f23bd0dedf4c0aa28c7b0c50fcdcdc54aa5b6bbba81a3941d"
ARG WKHTMLTOPDF_ARM64_CHECKSUM="b6606157b27c13e044d0abbe670301f88de4e1782afca4f9c06a5817f3e03a9c"
ARG WKHTMLTOPDF_URL="https://github.com/wkhtmltopdf/packaging/releases/download/${WKHTMLTOPDF_VERSION}-3/wkhtmltox_${WKHTMLTOPDF_VERSION}-3.bookworm_${TARGETARCH}.deb"

RUN if [ "$TARGETARCH" = "arm64" ]; then \
    WKHTMLTOPDF_CHECKSUM=$WKHTMLTOPDF_ARM64_CHECKSUM; \
    elif [ "$TARGETARCH" = "amd64" ]; then \
    WKHTMLTOPDF_CHECKSUM=$WKHTMLTOPDF_AMD64_CHECKSUM; \
    else \
    echo "Unsupported architecture: $TARGETARCH" >&2; \
    exit 1; \
    fi \
    && curl -SLo wkhtmltox.deb ${WKHTMLTOPDF_URL} \
    && echo "Downloading wkhtmltopdf from: ${WKHTMLTOPDF_URL}" \
    && echo "Expected wkhtmltox checksum: ${WKHTMLTOPDF_CHECKSUM}" \
    && echo "Computed wkhtmltox checksum: $(sha256sum wkhtmltox.deb | awk '{ print $1 }')" \
    && echo "${WKHTMLTOPDF_CHECKSUM} wkhtmltox.deb" | sha256sum -c - \
    && apt-get update \
    && apt-get install -y --no-install-recommends ./wkhtmltox.deb \
    && rm -rf /var/lib/apt/lists/* wkhtmltox.deb

# Install latest postgresql-client
RUN echo 'deb http://apt.postgresql.org/pub/repos/apt/ bookworm-pgdg main' > /etc/apt/sources.list.d/pgdg.list \
    && GNUPGHOME="$(mktemp -d)" \
    && export GNUPGHOME \
    && repokey='B97B0AFCAA1A47F044F244A07FCC7D46ACCC4CF8' \
    && gpg --batch --keyserver keyserver.ubuntu.com --recv-keys "${repokey}" \
    && gpg --batch --armor --export "${repokey}" > /etc/apt/trusted.gpg.d/pgdg.gpg.asc \
    && gpgconf --kill all \
    && rm -rf "$GNUPGHOME" \
    && apt-get update  \
    && apt-get install --no-install-recommends -y postgresql-client \
    && rm -f /etc/apt/sources.list.d/pgdg.list \
    && rm -Rf /var/lib/apt/lists/* /tmp/*

# Clean system and remove unnecessary files
RUN apt-get autoremove && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*


# Settings virtualenv and uv
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/
ENV UV_LINK_MODE=copy \
    UV_COMPILE_BYTECODE=1 \
    UV_PYTHON_DOWNLOADS=never \
    UV_PROJECT_ENVIRONMENT=/workspace/.venv
ENV PATH="/workspace/.venv/bin:$PATH"

# Create Odoo user
ARG USERNAME="odoo"
ARG UID=1000
ARG GID=$UID
ARG USER_HOME="/home/$USERNAME"

RUN groupadd -g $GID $USERNAME -o \
    && useradd -l -md $USER_HOME -s /bin/zsh -u $UID -g $GID $USERNAME \
    && mkdir -p /var/lib/odoo \
    && chown -R $USERNAME /var/lib/odoo \
    && sync

VOLUME ["/var/lib/odoo"]

# Configure command history
RUN mkdir -p /commandhistory \
    && touch /commandhistory/.zsh_history \
    && chown -R $USERNAME /commandhistory \
    && sync

# Claude Code config (named volume mounts here; pre-create so it gets odoo ownership)
RUN mkdir -p $USER_HOME/.claude \
    && chown -R $USERNAME:$GID $USER_HOME/.claude \
    && sync

USER $USERNAME

RUN sh -c "$(wget -O- https://github.com/deluan/zsh-in-docker/releases/download/v1.2.1/zsh-in-docker.sh)" -- \
    -t robbyrussell \
    -a 'SPACESHIP_PROMPT_ADD_NEWLINE="false"' \
    -a 'SPACESHIP_PROMPT_SEPARATE_LINE="false"' \
    -p https://github.com/zsh-users/zsh-autosuggestions \
    -p https://github.com/zsh-users/zsh-completions \
    -p https://github.com/zsh-users/zsh-syntax-highlighting \
    -p git

RUN SNIPPET="autoload -Uz add-zsh-hook; append_history() { fc -W }; add-zsh-hook precmd append_history; export HISTFILE=/commandhistory/.zsh_history" \
    && echo "$SNIPPET" >> "$USER_HOME/.zshrc"
