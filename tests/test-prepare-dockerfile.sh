#!/bin/bash
# Test script for prepare-dockerfile.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
PREPARE_SCRIPT="$PROJECT_ROOT/scripts/prepare-dockerfile.sh"

echo "Testing prepare-dockerfile.sh..."

# Test 1: Should work with single-version image
echo "Test 1: Single-version image with version specified"
if bash "$PREPARE_SCRIPT" alpine "3.21" > /dev/null 2>&1; then
  source "$PREPARE_SCRIPT" alpine "3.21" > /dev/null 2>&1
  if [ "$version" = "3.21" ] && [ "$tag" = "alpine" ]; then
    echo "  ✓ PASS: Correctly processes single-version image"
  else
    echo "  ✗ FAIL: Incorrect version or tag (version=$version, tag=$tag)"
    exit 1
  fi
else
  echo "  ✗ FAIL: Should succeed with valid image and version"
  exit 1
fi

# Test 2: Should work with multi-version image
echo "Test 2: Multi-version image with version specified"
if bash "$PREPARE_SCRIPT" python "3.11-alpine3.21" > /dev/null 2>&1; then
  source "$PREPARE_SCRIPT" python "3.11-alpine3.21" > /dev/null 2>&1
  if [ "$version" = "3.11-alpine3.21" ] && [ "$tag" = "python" ]; then
    echo "  ✓ PASS: Correctly processes multi-version image"
  else
    echo "  ✗ FAIL: Incorrect version or tag (version=$version, tag=$tag)"
    exit 1
  fi
else
  echo "  ✗ FAIL: Should succeed with valid image and version"
  exit 1
fi

# Test 3: Should fail without version
echo "Test 3: Missing version parameter"
if bash "$PREPARE_SCRIPT" alpine 2>&1 | grep -q "Error.*Version must be specified"; then
  echo "  ✓ PASS: Correctly errors when version is missing"
else
  echo "  ✗ FAIL: Should error when version is missing"
  exit 1
fi

# Test 4: Should fail with invalid version
echo "Test 4: Invalid version"
if bash "$PREPARE_SCRIPT" alpine "invalid-version" 2>&1 | grep -q "Error.*not found"; then
  echo "  ✓ PASS: Correctly errors for invalid version"
else
  echo "  ✗ FAIL: Should error for invalid version"
  exit 1
fi

echo "All tests passed for prepare-dockerfile.sh"
