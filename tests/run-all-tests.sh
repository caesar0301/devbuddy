#!/bin/bash
# Test runner for all script tests

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "Running all script tests..."
echo ""

# Check dependencies
if ! command -v jq >/dev/null 2>&1; then
  echo -e "${RED}Error: jq is required but not installed${NC}" >&2
  exit 1
fi

if ! command -v yq >/dev/null 2>&1; then
  echo -e "${YELLOW}Warning: yq is not installed, some tests may fail${NC}" >&2
fi

# Track test results
PASSED=0
FAILED=0
SKIPPED=0

# Run each test script
for test_script in "$SCRIPT_DIR"/test-*.sh; do
  if [ ! -f "$test_script" ]; then
    continue
  fi
  
  test_name=$(basename "$test_script" .sh)
  echo "=========================================="
  echo "Running $test_name"
  echo "=========================================="
  
  if bash "$test_script"; then
    echo -e "${GREEN}✓ $test_name: PASSED${NC}"
    ((PASSED++))
  else
    exit_code=$?
    if [ $exit_code -eq 1 ]; then
      echo -e "${RED}✗ $test_name: FAILED${NC}"
      ((FAILED++))
    else
      echo -e "${YELLOW}⚠ $test_name: SKIPPED${NC}"
      ((SKIPPED++))
    fi
  fi
  echo ""
done

# Summary
echo "=========================================="
echo "Test Summary"
echo "=========================================="
echo -e "${GREEN}Passed: $PASSED${NC}"
if [ $FAILED -gt 0 ]; then
  echo -e "${RED}Failed: $FAILED${NC}"
fi
if [ $SKIPPED -gt 0 ]; then
  echo -e "${YELLOW}Skipped: $SKIPPED${NC}"
fi

if [ $FAILED -gt 0 ]; then
  exit 1
fi

exit 0
