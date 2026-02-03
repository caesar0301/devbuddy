#!/bin/bash
# Test script for list-image-versions.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
LIST_SCRIPT="$PROJECT_ROOT/scripts/list-image-versions.sh"

echo "Testing list-image-versions.sh..."

# Test 1: Should return array for single-version image
echo "Test 1: Single-version image (alpine)"
OUTPUT=$(bash "$LIST_SCRIPT" alpine)
if echo "$OUTPUT" | jq -e 'type == "array"' > /dev/null 2>&1; then
  VERSION_COUNT=$(echo "$OUTPUT" | jq 'length')
  if [ "$VERSION_COUNT" -eq 1 ]; then
    echo "  ✓ PASS: Returns array with 1 version"
  else
    echo "  ✗ FAIL: Expected 1 version, got $VERSION_COUNT"
    exit 1
  fi
else
  echo "  ✗ FAIL: Should return JSON array"
  exit 1
fi

# Test 2: Should return array for multi-version image
echo "Test 2: Multi-version image (python)"
OUTPUT=$(bash "$LIST_SCRIPT" python)
if echo "$OUTPUT" | jq -e 'type == "array"' > /dev/null 2>&1; then
  VERSION_COUNT=$(echo "$OUTPUT" | jq 'length')
  if [ "$VERSION_COUNT" -gt 1 ]; then
    echo "  ✓ PASS: Returns array with $VERSION_COUNT versions"
  else
    echo "  ✗ FAIL: Expected multiple versions, got $VERSION_COUNT"
    exit 1
  fi
else
  echo "  ✗ FAIL: Should return JSON array"
  exit 1
fi

# Test 3: Should fail for non-existent image
echo "Test 3: Non-existent image"
if bash "$LIST_SCRIPT" nonexistent-image 2>&1 | grep -q "Error"; then
  echo "  ✓ PASS: Correctly errors for non-existent image"
else
  echo "  ✗ FAIL: Should error for non-existent image"
  exit 1
fi

echo "All tests passed for list-image-versions.sh"
