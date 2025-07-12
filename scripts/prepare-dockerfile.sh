#!/bin/bash
# Usage: scripts/prepare-dockerfile.sh <image_name>
# Outputs: context, platforms, tag, version, dockerfile_path as environment variables
set -e

if [ -z "$1" ]; then
  echo "Usage: $0 <image_name>" >&2
  exit 1
fi

IMAGE_NAME="$1"
CONFIG_FILE="images/$IMAGE_NAME/config.yaml"

if [ ! -f "$CONFIG_FILE" ]; then
  echo "Error: Config file not found: $CONFIG_FILE" >&2
  exit 1
fi

CONTEXT=$(yq e '.context' "$CONFIG_FILE")
PLATFORMS=$(yq e -o=json '.platforms' "$CONFIG_FILE" | jq -r 'join(",")')
TAG=$(yq e '.tag' "$CONFIG_FILE")
VERSION=$(yq e '.version' "$CONFIG_FILE")
DOCKERFILE_SPEC=$(yq e '.dockerfile' "$CONFIG_FILE")

# Prepare Dockerfile
if [[ "$DOCKERFILE_SPEC" == images/* ]]; then
  DOCKERFILE_PATH="$DOCKERFILE_SPEC"
  echo "Using existing Dockerfile at $DOCKERFILE_PATH"
else
  DOCKERFILE_PATH="$CONTEXT/Dockerfile"
  mkdir -p "$(dirname "$DOCKERFILE_PATH")"
  echo "$DOCKERFILE_SPEC" > "$DOCKERFILE_PATH"
  echo "Created Dockerfile at $DOCKERFILE_PATH"
fi

# Output for GitHub Actions
{
  echo "context=$CONTEXT"
  echo "platforms=$PLATFORMS"
  echo "tag=$TAG"
  echo "version=$VERSION"
  echo "dockerfile_path=$DOCKERFILE_PATH"
} >> "$GITHUB_OUTPUT"

# Also export for local use
export context="$CONTEXT"
export platforms="$PLATFORMS"
export tag="$TAG"
export version="$VERSION"
export dockerfile_path="$DOCKERFILE_PATH" 