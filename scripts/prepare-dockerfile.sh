#!/bin/bash
# Usage: scripts/prepare-dockerfile.sh <image_name> [version]
# Outputs: context, platforms, tag, version, dockerfile_path as environment variables
# Requires multi-version config format with 'versions' field
set -e

if [ -z "$1" ]; then
  echo "Usage: $0 <image_name> [version]" >&2
  exit 1
fi

IMAGE_NAME="$1"
VERSION_OVERRIDE="$2"
CONFIG_FILE="images/$IMAGE_NAME/config.yaml"

if [ ! -f "$CONFIG_FILE" ]; then
  echo "Error: Config file not found: $CONFIG_FILE" >&2
  exit 1
fi

CONTEXT=$(yq e '.context' "$CONFIG_FILE")
PLATFORMS=$(yq e -o=json '.platforms' "$CONFIG_FILE" | jq -r 'join(",")')
TAG=$(yq e '.tag' "$CONFIG_FILE")

# Multi-version format is required
HAS_VERSIONS=$(yq e '.versions // null' "$CONFIG_FILE")
if [ "$HAS_VERSIONS" == "null" ] || [ -z "$HAS_VERSIONS" ]; then
  echo "Error: Config must use multi-version format with 'versions' field" >&2
  exit 1
fi

if [ -z "$VERSION_OVERRIDE" ]; then
  echo "Error: Version must be specified. Available versions:" >&2
  yq e '.versions | keys | .[]' "$CONFIG_FILE" >&2
  exit 1
fi

# Check if version exists
VERSION_EXISTS=$(yq e ".versions.\"$VERSION_OVERRIDE\" // null" "$CONFIG_FILE")
if [ "$VERSION_EXISTS" == "null" ]; then
  echo "Error: Version '$VERSION_OVERRIDE' not found in config. Available versions:" >&2
  yq e '.versions | keys | .[]' "$CONFIG_FILE" >&2
  exit 1
fi

VERSION="$VERSION_OVERRIDE"
# Get version-specific dockerfile, or fall back to root dockerfile, or default
DOCKERFILE_SPEC=$(yq e ".versions.\"$VERSION\".dockerfile // .dockerfile // \"\"" "$CONFIG_FILE")

# Prepare Dockerfile
# Rules:
# 1. If dockerfile is absent or empty -> use default Dockerfile at "$CONTEXT/Dockerfile".
# 2. If dockerfile is a single-line string -> treat it as a path relative to context.
# 3. If dockerfile is a multi-line string -> treat it as inline Dockerfile content and
#    write it to "$CONTEXT/Dockerfile".
if [[ -z "$DOCKERFILE_SPEC" || "$DOCKERFILE_SPEC" == "null" ]]; then
  # No dockerfile specified: use default Dockerfile in the context directory.
  DOCKERFILE_PATH="$CONTEXT/Dockerfile"
  echo "Using default Dockerfile at $DOCKERFILE_PATH"
elif [[ "$DOCKERFILE_SPEC" != *$'\n'* ]]; then
  # Single-line value: interpret as a Dockerfile path relative to context.
  if [[ "$DOCKERFILE_SPEC" = /* ]]; then
    # Absolute path (rare, but allow it explicitly).
    DOCKERFILE_PATH="$DOCKERFILE_SPEC"
  else
    DOCKERFILE_PATH="$CONTEXT/$DOCKERFILE_SPEC"
  fi
  echo "Using Dockerfile at $DOCKERFILE_PATH"
else
  # Multi-line value: treat as Dockerfile content.
  DOCKERFILE_PATH="$CONTEXT/Dockerfile"
  mkdir -p "$(dirname "$DOCKERFILE_PATH")"
  printf '%s\n' "$DOCKERFILE_SPEC" > "$DOCKERFILE_PATH"
  echo "Created Dockerfile at $DOCKERFILE_PATH from inline dockerfile content"
fi

# Output for GitHub Actions (if running in CI)
if [ -n "$GITHUB_OUTPUT" ]; then
  {
    echo "context=$CONTEXT"
    echo "platforms=$PLATFORMS"
    echo "tag=$TAG"
    echo "version=$VERSION"
    echo "dockerfile_path=$DOCKERFILE_PATH"
  } >> "$GITHUB_OUTPUT"
fi

# Also export for local use
export context="$CONTEXT"
export platforms="$PLATFORMS"
export tag="$TAG"
export version="$VERSION"
export dockerfile_path="$DOCKERFILE_PATH" 