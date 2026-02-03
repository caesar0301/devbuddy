#!/bin/bash
# Usage: scripts/expand-matrix.sh <changed_images.json>
# Reads changed_images.json and expands each image into matrix entries with all versions
# Outputs: matrix JSON and has_changes flag to GITHUB_OUTPUT
set -e

CHANGED_IMAGES_FILE="${1:-changed_images.json}"

if [ ! -f "$CHANGED_IMAGES_FILE" ]; then
  echo "Error: Changed images file not found: $CHANGED_IMAGES_FILE" >&2
  exit 1
fi

# Expand multi-version images into matrix entries
# All images now use multi-version format, so VERSIONS is always an array
EXPANDED_MATRIX="[]"
CHANGED_IMAGES=$(cat "$CHANGED_IMAGES_FILE")

if [ "$CHANGED_IMAGES" = "[]" ]; then
  HAS_CHANGES=false
else
  HAS_CHANGES=true
  for image_name in $(echo "$CHANGED_IMAGES" | jq -r '.[]'); do
    VERSIONS=$(bash scripts/list-image-versions.sh "$image_name")
    # VERSIONS is always an array [{"name": "v1"}, {"name": "v2"}, ...]
    for version_obj in $(echo "$VERSIONS" | jq -c '.[]'); do
      VERSION=$(echo "$version_obj" | jq -r '.name')
      EXPANDED_MATRIX=$(echo "$EXPANDED_MATRIX" | jq -c --arg img "$image_name" --arg ver "$VERSION" '. + [{"name": $img, "version": $ver}]')
    done
  done
fi

# Output for GitHub Actions
if [ -n "$GITHUB_OUTPUT" ]; then
  echo "matrix=$EXPANDED_MATRIX" >> "$GITHUB_OUTPUT"
  echo "has_changes=$HAS_CHANGES" >> "$GITHUB_OUTPUT"
fi

# Also output to stdout for debugging (format: key=value for easy parsing)
echo "matrix=$EXPANDED_MATRIX"
echo "has_changes=$HAS_CHANGES"
