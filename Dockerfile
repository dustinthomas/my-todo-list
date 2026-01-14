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
# Note: Pkg.precompile() will be added in Phase 3 when source files exist
RUN julia --project=. -e 'using Pkg; Pkg.instantiate()'

# Keep container running for interactive use
CMD ["tail", "-f", "/dev/null"]
