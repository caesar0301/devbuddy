#!/bin/bash
# Usage: scripts/list-image-versions.sh <image_name>
# Outputs: JSON array of version objects with name, or single version object
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

# Multi-version format is required
HAS_VERSIONS=$(yq e '.versions // null' "$CONFIG_FILE")
if [ "$HAS_VERSIONS" == "null" ] || [ -z "$HAS_VERSIONS" ]; then
  echo "Error: Config must use multi-version format with 'versions' field" >&2
  exit 1
fi

# Output all versions as JSON array
yq e -o=json '.versions | keys | map({"name": .})' "$CONFIG_FILE"
