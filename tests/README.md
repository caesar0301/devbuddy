# Script Tests

This directory contains test scripts for all scripts in the `scripts/` directory.

## Running Tests

### Run all tests
```bash
bash tests/run-all-tests.sh
```

### Run individual test
```bash
bash tests/test-<script-name>.sh
```

## Test Scripts

- `test-validate-image-configs.sh` - Tests image config validation
- `test-list-image-versions.sh` - Tests version listing functionality
- `test-prepare-dockerfile.sh` - Tests Dockerfile preparation
- `test-expand-matrix.sh` - Tests matrix expansion for CI/CD
- `test-detect-changes.sh` - Tests change detection

## Requirements

- `bash` - Shell interpreter
- `jq` - JSON processor (required)
- `yq` - YAML processor (recommended, some tests may skip if not available)

## Test Output

Tests output:
- ✓ PASS - Test passed
- ✗ FAIL - Test failed
- ⚠ SKIP - Test skipped (usually due to missing dependencies or environment)

The test runner provides a summary at the end showing passed, failed, and skipped tests.
