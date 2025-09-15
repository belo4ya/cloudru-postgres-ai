# AGENTS.md

## Build Commands
```bash
# Build default PostgreSQL 16 image with AI extensions
make build

# Build specific PostgreSQL versions
make pg15
make pg16
make pg17

# Build all PostgreSQL versions
make all

# Build with Docker bake
docker buildx bake
docker buildx bake pg16
docker buildx bake all
```

## Test Commands
Testing is primarily done by running the built Docker images and verifying functionality:
```bash
# Run the built image
docker run -it belo4ya/cnpg-postgresql:16.9-bookworm-ai

# Test specific extensions within the container
docker run -it belo4ya/cnpg-postgresql:16.9-bookworm-ai psql -c "CREATE EXTENSION vector;"
```

## Code Style Guidelines

### Dockerfile Structure
- Multi-stage builds with builder, trimmed, and final stages
- Alphabetical ordering of packages and extensions where possible
- Clear section comments (e.g., `# --------------------- pgvector`)
- Version pinning for all dependencies

### Extension Management
- Each extension gets its own commented section
- Include GitHub repository link in comments
- Use ARG variables for versioning
- Install extensions in a consistent, predictable order

### Naming Conventions
- Use lowercase with underscores for ARG variables
- Use descriptive names for build stages
- Follow semantic versioning for tags

### Error Handling
- Use `set -e` for failing on errors
- Check exit codes for critical operations
- Provide informative error messages

### Formatting
- Indent with spaces (2 or 4 spaces)
- Line length maximum 120 characters
- Consistent spacing around operators
- Empty lines between logical sections

### Makefile Standards
- Use `?=` for overridable variables
- Provide help text for complex targets
- Use `.PHONY` for non-file targets