FROM julia:1.12-bookworm

# Install build dependencies for native packages
RUN apt-get update && apt-get install -y \
    git \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy package manifest (Docker layer caching)
COPY Project.toml Manifest.toml* ./

# Instantiate packages (cached until Project.toml changes)
RUN julia --project=. -e 'using Pkg; Pkg.instantiate()'

# Copy entrypoint script
COPY scripts/docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# Use entrypoint to sync packages when Manifest.toml changes (handles machine switches)
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]

# Keep container running for interactive use
CMD ["tail", "-f", "/dev/null"]
