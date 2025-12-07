# VLC Telnet - Developer & Maintainer Guide

## Building and Publishing Docker Images

This guide covers how to build, test, and publish the VLC Telnet Docker image with multi-platform support and Docker best practices.

## Prerequisites

- Docker with BuildKit enabled (Docker 20.10+)
- Docker Hub account with push permissions to `ne1ver/vlc-telnet`
- Access to this repository

## Architecture Overview

The Dockerfile uses a **single-stage build** with Docker best practices:

- Installs VLC, ALSA utilities, and dependencies in one optimized layer
- Creates non-root user with proper audio permissions
- Implements aggressive cleanup for minimal image size
- Follows Docker security and layer optimization best practices

## Local Development Build

### 1. Quick Local Build

```bash
# Build the image locally
docker build \
    --progress=plain \
    --tag vlc-telnet:test \
    .
```

### 2. Test with Development Docker Compose

```bash
# Set required environment variables
export VLC_TELNET_PASSWORD=dev_password_123
export ALSA_DEVICE=USB Audio

# Build and run with dev compose
docker compose -f docker-compose.dev.yaml build
docker compose -f docker-compose.dev.yaml up -d
```

### 3. Verify the Build

```bash
# Verify container is running
docker compose -f docker-compose.dev.yaml ps

# Check logs for proper audio device detection
docker compose -f docker-compose.dev.yaml logs vlc-telnet
```

### 4. Test Telnet Connection

```bash
# Connect to VLC telnet interface
telnet localhost 4212

# Use password: dev_password_123
# Test VLC commands like:
# help
# volume 256
# status
```

## Multi-Platform Production Build

### 1. Setup BuildKit Builder

```bash
# Create multi-platform builder
docker buildx create --name multiarch --use

# Verify builder is ready
docker buildx inspect --bootstrap

# Should show support for linux/386, linux/amd64, linux/arm/v7, linux/arm64
```

### 2. Multi-Platform Build

```bash
# Build for all supported platforms
docker buildx build \
    --platform linux/386,linux/amd64,linux/arm/v7,linux/arm64 \
    --tag ne1ver/vlc-telnet:1.0.0 \
    --tag ne1ver/vlc-telnet:latest \
    --push .
```

### 3. Verify Multi-Platform Image

```bash
# Check manifest list shows both platforms
docker buildx imagetools inspect ne1ver/vlc-telnet:latest

# Should output something like:
# Name:      docker.io/ne1ver/vlc-telnet:latest
# MediaType: application/vnd.docker.distribution.manifest.list.v2+json
# Digest:    sha256:abc123...
#
# Manifests:
#   Name:      docker.io/ne1ver/vlc-telnet:latest@sha256:def456...
#   MediaType: application/vnd.docker.distribution.manifest.v2+json
#   Platform:  linux/amd64
#
#   Name:      docker.io/ne1ver/vlc-telnet:latest@sha256:ghi789...
#   MediaType: application/vnd.docker.distribution.manifest.v2+json
#   Platform:  linux/arm64
```

## Publishing to Docker Hub

### First Time Setup

```bash
# Login to Docker Hub
docker login

# Verify you have push access
docker pull ne1ver/vlc-telnet:latest
```

### Release Process

#### 1. Update Version Information

Edit the version label in `Dockerfile`:

```dockerfile
LABEL version="1.0.1" \
      description="VLC telnet server with automated minimal dependencies" \
      org.opencontainers.image.source="https://github.com/en-ver/vlc-telnet"
```

#### 2. Build and Push New Release

```bash
# Build and push versioned tag
docker buildx build \
    --platform linux/386,linux/amd64,linux/arm/v7,linux/arm64 \
    --tag ne1ver/vlc-telnet:1.0.1 \
    --push .

# Update latest tag (if this is the current stable release)
docker buildx build \
    --platform linux/386,linux/amd64,linux/arm/v7,linux/arm64 \
    --tag ne1ver/vlc-telnet:latest \
    --push .
```

#### 3. Update GitHub Release (Optional)

- Create new release in GitHub repository
- Add release notes with changes
- Reference new Docker image tags

## File Structure

```bash
vlc-telnet/
├── Dockerfile                    # Single-stage Dockerfile with best practices
├── entrypoint.sh                 # VLC startup script with audio detection
├── docker-compose.dev.yaml      # Development compose with multi-platform support
├── docker-compose.yaml         # Production compose configuration
├── README-dev.md                 # This developer guide
├── README.md                     # User documentation
└── .env.template               # Environment variables template
```

## Testing Checklist

Before releasing, verify:

- Image builds successfully for all platforms
- Container starts without errors
- Telnet interface responds on port 4212
- Audio device detection works
- Health check passes
- All platforms work: linux/386, linux/amd64, linux/arm/v7, linux/arm64
- Documentation is updated

## Monitoring and Maintenance

### 1. Dependency Updates

Monitor for VLC/ALSA updates:

```bash
# Check for package updates
docker run --rm debian:stable-slim \
    sh -c "apt-get update > /dev/null 2>&1 && apt-cache policy vlc alsa-utils"
```

### 2. Security Scanning

```bash
# Scan for vulnerabilities (if available)
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
    aquasec/trivy image ne1ver/vlc-telnet:latest
```

## Rollback Procedures

### 1. If New Build Fails

```bash
# Re-tag previous version as latest
docker buildx imagetools inspect ne1ver/vlc-telnet:1.0.0
docker buildx imagetools create \
    --tag ne1ver/vlc-telnet:latest \
    ne1ver/vlc-telnet:1.0.0
```

### 2. Emergency Hotfix

```bash
# Quick patch without version bump
docker buildx build \
    --platform linux/386,linux/amd64,linux/arm/v7,linux/arm64 \
    --tag ne1ver/vlc-telnet:latest \
    --push .
```
