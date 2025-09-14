# AGENTS.md

## Build Commands
- `make builder` - Create buildx builder
- `make build` - Build docker image locally
- `make pg15`, `make pg16`, `make pg17` - Build specific PostgreSQL versions
- `make all` - Build all versions
- `make rm-builder` - Remove buildx builder

## Test Commands
- Run a single test with: `docker run -it --rm <image-name> pg_isready`
- Manual testing: Run container and verify extensions load
- Connect to PostgreSQL and verify extensions are available with `\dx`
- Test extension functionality through SQL queries
- Validate build-info.txt contains correct version information

## Lint/Format Commands
- No specific linting/formatting tools identified
- Follow Dockerfile best practices and CloudNativePG patterns

## Code Style Guidelines
- Follow CloudNativePG Dockerfile patterns
- Use multi-stage builds for size optimization
- Install packages with explicit versions
- Strip binaries to reduce image size
- Clean up build artifacts and caches
- Use ARG for versioning extensions
- Extensions should be built/installed in dedicated sections
- Use consistent labeling for image metadata

## Extension Installation Patterns
- Prefer installing from official Debian packages when available
- For Rust-based extensions, use cargo-pgrx for installation
- Download pre-built binaries when available from official sources
- Always clean up temporary files after installation
- Strip shared object files to reduce image size