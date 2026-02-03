#!/bin/bash
# Test script for force_build_all functionality

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "Testing force_build_all functionality..."

# Test 1: Generate changed_images.json like force_build_all would
echo "Test 1: Generate all images list"
cd "$PROJECT_ROOT"
find images -name "config.yaml" -type f | \
  sed 's|images/||;s|/config.yaml||' | \
  grep -v '^$' | \
  jq -R . | \
  jq -s . > /tmp/test-force-images.json

IMAGE_COUNT=$(cat /tmp/test-force-images.json | jq 'length')
if [ "$IMAGE_COUNT" -gt 0 ]; then
  echo "  ✓ PASS: Generated list with $IMAGE_COUNT images"
else
  echo "  ✗ FAIL: No images found"
  exit 1
fi

# Test 2: Verify JSON format is correct
echo "Test 2: Verify JSON format"
if cat /tmp/test-force-images.json | jq -e '.' > /dev/null 2>&1; then
  echo "  ✓ PASS: Valid JSON format"
else
  echo "  ✗ FAIL: Invalid JSON format"
  exit 1
fi

# Test 3: Verify expand-matrix works with force_build_all output
echo "Test 3: Expand matrix from force_build_all output"
export GITHUB_OUTPUT=/tmp/test-force-output
rm -f "$GITHUB_OUTPUT"

if bash "$PROJECT_ROOT/scripts/expand-matrix.sh" /tmp/test-force-images.json > /tmp/test-expand.log 2>&1; then
  if [ -f "$GITHUB_OUTPUT" ]; then
    MATRIX=$(grep "^matrix=" "$GITHUB_OUTPUT" | sed 's/^matrix=//')
    HAS_CHANGES=$(grep "^has_changes=" "$GITHUB_OUTPUT" | sed 's/^has_changes=//')
    
    if [ "$HAS_CHANGES" = "true" ]; then
      MATRIX_COUNT=$(echo "$MATRIX" | jq 'length')
      if [ "$MATRIX_COUNT" -gt "$IMAGE_COUNT" ]; then
        echo "  ✓ PASS: Matrix expanded correctly ($MATRIX_COUNT entries from $IMAGE_COUNT images)"
      else
        echo "  ✗ FAIL: Matrix count ($MATRIX_COUNT) should be greater than image count ($IMAGE_COUNT)"
        exit 1
      fi
    else
      echo "  ✗ FAIL: has_changes should be true"
      exit 1
    fi
  else
    echo "  ✗ FAIL: GITHUB_OUTPUT not created"
    exit 1
  fi
else
  echo "  ✗ FAIL: expand-matrix.sh failed"
  cat /tmp/test-expand.log
  exit 1
fi

echo "All tests passed for force_build_all functionality"
