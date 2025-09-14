# AGENTS.md

## Build Commands
- `cd extensions/docker && make builder` - Setup Docker buildx builder
- `cd extensions/docker && make build` - Build Docker image locally
- `cd extensions/docker && make all` - Build all images
- `cd extensions/docker && make pg16` - Build PostgreSQL 16 image

## Code Style Guidelines
- No specific style guides found in codebase
- Follow standard Dockerfile best practices
- Use multi-stage builds where appropriate
- Pin base image versions explicitly
- Use .dockerignore to exclude unnecessary files

## Repository Structure
- `extensions/docker/` - Docker build files and configurations
- `mcp/` - Model Context Protocol configurations and samples

## Testing
- No automated test framework identified
- Manual testing through Docker build process
- Validate images with `docker run` commands

## Important Notes
- Project focused on PostgreSQL AI extensions in Docker
- Uses buildx for multi-platform image building
- Integrates with Cloud.ru services and opencode.ai
- Check mcp/README.md for detailed usage instructions