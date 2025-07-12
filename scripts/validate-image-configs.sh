#!/bin/bash
# Validate all images/*/config.yaml files for YAML syntax and required fields
set -e

REQUIRED_FIELDS=(platforms context tag version dockerfile)

for config in images/*/config.yaml; do
  echo "Validating $config"
  if ! yq e '.' "$config" > /dev/null; then
    echo "Error: Invalid YAML syntax in $config"
    exit 1
  fi
  for field in "${REQUIRED_FIELDS[@]}"; do
    if ! yq e ".$field" "$config" > /dev/null; then
      echo "Error: Missing required field '$field' in $config"
      exit 1
    fi
  done
  echo "  ✓ $config is valid"
done 