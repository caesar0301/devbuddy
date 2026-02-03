#!/bin/bash
# Test script for validate-image-configs.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
VALIDATE_SCRIPT="$PROJECT_ROOT/scripts/validate-image-configs.sh"

echo "Testing validate-image-configs.sh..."

# Test 1: Should pass with valid multi-version config
echo "Test 1: Valid multi-version config"
if bash "$VALIDATE_SCRIPT" > /dev/null 2>&1; then
  echo "  ✓ PASS: Valid configs validated successfully"
else
  echo "  ✗ FAIL: Should pass with valid configs"
  exit 1
fi

echo "All tests passed for validate-image-configs.sh"
