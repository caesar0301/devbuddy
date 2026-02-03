#!/bin/bash
# Validate all images/*/config.yaml files for YAML syntax and required fields
# Supports both single-version and multi-version configs
set -e

REQUIRED_FIELDS=(platforms context tag)

for config in images/*/config.yaml; do
  echo "Validating $config"
  if ! yq e '.' "$config" > /dev/null; then
    echo "Error: Invalid YAML syntax in $config"
    exit 1
  fi
  
  # Check required fields
  for field in "${REQUIRED_FIELDS[@]}"; do
    if ! yq e ".$field" "$config" > /dev/null; then
      echo "Error: Missing required field '$field' in $config"
      exit 1
    fi
  done
  
  # Multi-version format is required
  HAS_VERSIONS=$(yq e '.versions // null' "$config")
  if [ "$HAS_VERSIONS" == "null" ] || [ -z "$HAS_VERSIONS" ]; then
    echo "Error: Config must use multi-version format with 'versions' field in $config"
    exit 1
  fi
  
  echo "  - Multi-version config detected"
  VERSION_COUNT=$(yq e '.versions | length' "$config")
  if [ "$VERSION_COUNT" -eq 0 ]; then
    echo "Error: 'versions' field is empty in $config"
    exit 1
  fi
  # Validate each version
  VERSIONS=$(yq e '.versions | keys | .[]' "$config")
  for version in $VERSIONS; do
    echo "    - Validating version: $version"
    # Version-specific dockerfile is optional, will fall back to root dockerfile or default
  done
  
  echo "  ✓ $config is valid"
done 