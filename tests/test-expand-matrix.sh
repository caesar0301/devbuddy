#!/bin/bash
# Test script for expand-matrix.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
EXPAND_SCRIPT="$PROJECT_ROOT/scripts/expand-matrix.sh"

echo "Testing expand-matrix.sh..."

# Create temporary test files
TEMP_DIR=$(mktemp -d)
trap "rm -rf $TEMP_DIR" EXIT

# Test 1: Empty changes (no images changed)
echo "Test 1: Empty changes"
echo "[]" > "$TEMP_DIR/empty.json"
OUTPUT=$(bash "$EXPAND_SCRIPT" "$TEMP_DIR/empty.json" 2>&1)
if echo "$OUTPUT" | grep -q "has_changes=false"; then
  MATRIX=$(echo "$OUTPUT" | grep "^matrix=" | sed 's/^matrix=//')
  if echo "$MATRIX" | jq -e '. == []' > /dev/null 2>&1; then
    echo "  ✓ PASS: Correctly handles empty changes"
  else
    echo "  ✗ FAIL: Matrix should be empty"
    exit 1
  fi
else
  echo "  ✗ FAIL: Should indicate no changes"
  exit 1
fi

# Test 2: Single image with single version
echo "Test 2: Single image with single version"
echo '["alpine"]' > "$TEMP_DIR/single.json"
OUTPUT=$(bash "$EXPAND_SCRIPT" "$TEMP_DIR/single.json" 2>&1)
if echo "$OUTPUT" | grep -q "has_changes=true"; then
  MATRIX=$(echo "$OUTPUT" | grep "^matrix=" | sed 's/^matrix=//')
  MATRIX_COUNT=$(echo "$MATRIX" | jq 'length')
  if [ "$MATRIX_COUNT" -eq 1 ]; then
    IMG_NAME=$(echo "$MATRIX" | jq -r '.[0].name')
    if [ "$IMG_NAME" = "alpine" ]; then
      echo "  ✓ PASS: Correctly expands single image with single version"
    else
      echo "  ✗ FAIL: Wrong image name: $IMG_NAME"
      exit 1
    fi
  else
    echo "  ✗ FAIL: Expected 1 matrix entry, got $MATRIX_COUNT"
    exit 1
  fi
else
  echo "  ✗ FAIL: Should indicate changes"
  exit 1
fi

# Test 3: Single image with multiple versions
echo "Test 3: Single image with multiple versions"
echo '["python"]' > "$TEMP_DIR/multi.json"
OUTPUT=$(bash "$EXPAND_SCRIPT" "$TEMP_DIR/multi.json" 2>&1)
if echo "$OUTPUT" | grep -q "has_changes=true"; then
  MATRIX=$(echo "$OUTPUT" | grep "^matrix=" | sed 's/^matrix=//')
  MATRIX_COUNT=$(echo "$MATRIX" | jq 'length')
  if [ "$MATRIX_COUNT" -gt 1 ]; then
    echo "  ✓ PASS: Correctly expands single image with $MATRIX_COUNT versions"
  else
    echo "  ✗ FAIL: Expected multiple versions, got $MATRIX_COUNT"
    exit 1
  fi
else
  echo "  ✗ FAIL: Should indicate changes"
  exit 1
fi

# Test 4: Multiple images
echo "Test 4: Multiple images"
echo '["alpine", "redis"]' > "$TEMP_DIR/multiple.json"
OUTPUT=$(bash "$EXPAND_SCRIPT" "$TEMP_DIR/multiple.json" 2>&1)
if echo "$OUTPUT" | grep -q "has_changes=true"; then
  MATRIX=$(echo "$OUTPUT" | grep "^matrix=" | sed 's/^matrix=//')
  MATRIX_COUNT=$(echo "$MATRIX" | jq 'length')
  if [ "$MATRIX_COUNT" -ge 2 ]; then
    echo "  ✓ PASS: Correctly expands multiple images with $MATRIX_COUNT total entries"
  else
    echo "  ✗ FAIL: Expected at least 2 entries, got $MATRIX_COUNT"
    exit 1
  fi
else
  echo "  ✗ FAIL: Should indicate changes"
  exit 1
fi

echo "All tests passed for expand-matrix.sh"
