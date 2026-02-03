#!/bin/bash
# Test script to simulate GitHub Actions workflow jobs locally
# Tests each job in .github/workflows/build-images.yml

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Track results
PASSED=0
FAILED=0

print_header() {
    echo ""
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}"
}

print_test() {
    echo -e "${YELLOW}Testing: $1${NC}"
}

print_pass() {
    echo -e "${GREEN}  ✓ PASS: $1${NC}"
    PASSED=$((PASSED + 1))
}

print_fail() {
    echo -e "${RED}  ✗ FAIL: $1${NC}"
    FAILED=$((FAILED + 1))
}

# Check dependencies
check_dependencies() {
    print_header "Checking Dependencies"
    
    local missing=0
    
    if ! command -v jq >/dev/null 2>&1; then
        print_fail "jq is not installed"
        missing=1
    else
        print_pass "jq is installed"
    fi
    
    if command -v yq >/dev/null 2>&1; then
        print_pass "yq is installed"
    else
        print_fail "yq is not installed"
        echo "  Note: yq will be installed in CI workflow"
        missing=1
    fi
    
    if ! command -v python3 >/dev/null 2>&1; then
        print_fail "python3 is not installed"
        missing=1
    else
        print_pass "python3 is installed"
    fi
    
    # Check if PyYAML is installed
    if python3 -c "import yaml" 2>/dev/null; then
        print_pass "PyYAML is installed"
    else
        echo "  Note: PyYAML not installed locally (will be installed in CI)"
        echo "  Skipping PyYAML check - workflow will install it"
        # Don't fail - the workflow installs it
    fi
    
    if [ $missing -eq 1 ]; then
        echo -e "${RED}Some critical dependencies are missing. Please install them and try again.${NC}"
        exit 1
    fi
}

# Test Job 1: validate-config
test_validate_config_job() {
    print_header "Job 1: validate-config"
    
    cd "$PROJECT_ROOT"
    
    print_test "Step: Install yq and PyYAML"
    # Already checked in dependencies, just verify
    if command -v yq >/dev/null 2>&1; then
        print_pass "yq available (PyYAML will be installed in CI)"
    else
        print_fail "yq not available"
        return 1
    fi
    
    print_test "Step: Validate all image configs"
    if bash scripts/validate-image-configs.sh > /tmp/validate-output.log 2>&1; then
        print_pass "All image configs validated successfully"
    else
        print_fail "Config validation failed"
        echo "  Output:"
        cat /tmp/validate-output.log | sed 's/^/    /'
        return 1
    fi
}

# Test Job 2: filter-changes
test_filter_changes_job() {
    print_header "Job 2: filter-changes"
    
    cd "$PROJECT_ROOT"
    
    print_test "Step: Install yq and PyYAML"
    if command -v yq >/dev/null 2>&1; then
        print_pass "yq available (PyYAML will be installed in CI)"
    else
        print_fail "yq not available"
        return 1
    fi
    
    print_test "Step: Detect changed images"
    # Simulate the workflow step
    # Use HEAD~1 and HEAD if in git repo, otherwise use a test scenario
    if [ -d .git ]; then
        # Get the last two commits
        COMMIT_BEFORE=$(git rev-parse HEAD~1 2>/dev/null || echo "HEAD~1")
        COMMIT_AFTER=$(git rev-parse HEAD 2>/dev/null || echo "HEAD")
        
        if bash scripts/detect-changes.sh "$COMMIT_BEFORE" "$COMMIT_AFTER" > /tmp/detect-output.log 2>&1; then
            print_pass "Change detection completed"
        else
            # Check if it's just because there are no changes
            if [ -f changed_images.json ]; then
                print_pass "Change detection completed (may have no changes)"
            else
                print_fail "Change detection failed"
                echo "  Output:"
                cat /tmp/detect-output.log | sed 's/^/    /'
                return 1
            fi
        fi
    else
        # Not in git repo, create a mock changed_images.json
        echo '["alpine"]' > changed_images.json
        print_pass "Created mock changed_images.json for testing"
    fi
    
    if [ ! -f changed_images.json ]; then
        print_fail "changed_images.json not created"
        return 1
    fi
    
    print_test "Step: Expand matrix"
    # Simulate GITHUB_OUTPUT
    export GITHUB_OUTPUT="/tmp/github-output-test"
    rm -f "$GITHUB_OUTPUT"
    
    if bash scripts/expand-matrix.sh changed_images.json > /tmp/expand-output.log 2>&1; then
        print_pass "Matrix expansion completed"
        
        # Check GITHUB_OUTPUT
        if [ -f "$GITHUB_OUTPUT" ]; then
            if grep -q "matrix=" "$GITHUB_OUTPUT" && grep -q "has_changes=" "$GITHUB_OUTPUT"; then
                print_pass "GITHUB_OUTPUT created correctly"
                echo "  Matrix output:"
                grep "matrix=" "$GITHUB_OUTPUT" | sed 's/^/    /'
                grep "has_changes=" "$GITHUB_OUTPUT" | sed 's/^/    /'
            else
                print_fail "GITHUB_OUTPUT missing required fields"
                return 1
            fi
        else
            print_fail "GITHUB_OUTPUT file not created"
            return 1
        fi
    else
        print_fail "Matrix expansion failed"
        echo "  Output:"
        cat /tmp/expand-output.log | sed 's/^/    /'
        return 1
    fi
    
    # Test the matrix format
    MATRIX_VALUE=$(grep "matrix=" "$GITHUB_OUTPUT" | sed 's/matrix=//')
    if echo "$MATRIX_VALUE" | jq -e '.' > /dev/null 2>&1; then
        print_pass "Matrix is valid JSON"
        MATRIX_COUNT=$(echo "$MATRIX_VALUE" | jq 'length')
        echo "    Matrix contains $MATRIX_COUNT entries"
    else
        print_fail "Matrix is not valid JSON"
        return 1
    fi
}

# Test Job 3: build-and-push (preparation steps only)
test_build_and_push_job() {
    print_header "Job 3: build-and-push (preparation steps)"
    
    cd "$PROJECT_ROOT"
    
    print_test "Step: Install yq and PyYAML"
    if command -v yq >/dev/null 2>&1; then
        print_pass "yq available (PyYAML will be installed in CI)"
    else
        print_fail "yq not available"
        return 1
    fi
    
    print_test "Step: Prepare Dockerfile and config"
    # Test with a few different images/versions including single-line inline Dockerfile
    TEST_CASES=(
        "alpine 3.21"
        "python 3.11-alpine3.21"
        "ubuntu 22.04"
        "savant-deepstream latest"
    )
    
    for test_case in "${TEST_CASES[@]}"; do
        IMAGE_NAME=$(echo $test_case | cut -d' ' -f1)
        VERSION=$(echo $test_case | cut -d' ' -f2)
        
        # Simulate GITHUB_OUTPUT
        export GITHUB_OUTPUT="/tmp/github-output-prepare-$IMAGE_NAME"
        rm -f "$GITHUB_OUTPUT"
        
        if bash scripts/prepare-dockerfile.sh "$IMAGE_NAME" "$VERSION" > /tmp/prepare-output.log 2>&1; then
            if [ -f "$GITHUB_OUTPUT" ]; then
                if grep -q "context=" "$GITHUB_OUTPUT" && \
                   grep -q "platforms=" "$GITHUB_OUTPUT" && \
                   grep -q "tag=" "$GITHUB_OUTPUT" && \
                   grep -q "version=" "$GITHUB_OUTPUT" && \
                   grep -q "dockerfile_path=" "$GITHUB_OUTPUT"; then
                    print_pass "Prepare step works for $IMAGE_NAME:$VERSION"
                else
                    print_fail "GITHUB_OUTPUT missing fields for $IMAGE_NAME:$VERSION"
                    cat "$GITHUB_OUTPUT" | sed 's/^/    /'
                    return 1
                fi
            else
                print_fail "GITHUB_OUTPUT not created for $IMAGE_NAME:$VERSION"
                return 1
            fi
        else
            print_fail "Prepare step failed for $IMAGE_NAME:$VERSION"
            echo "  Output:"
            cat /tmp/prepare-output.log | sed 's/^/    /'
            return 1
        fi
    done
    
    print_test "Step: Verify output format matches workflow expectations"
    # Check that the outputs can be used in workflow context
    export GITHUB_OUTPUT="/tmp/github-output-final"
    rm -f "$GITHUB_OUTPUT"
    bash scripts/prepare-dockerfile.sh alpine "3.21" > /dev/null 2>&1
    
    CONTEXT=$(grep "context=" "$GITHUB_OUTPUT" | sed 's/context=//')
    PLATFORMS=$(grep "platforms=" "$GITHUB_OUTPUT" | sed 's/platforms=//')
    TAG=$(grep "tag=" "$GITHUB_OUTPUT" | sed 's/tag=//')
    VERSION=$(grep "version=" "$GITHUB_OUTPUT" | sed 's/version=//')
    DOCKERFILE_PATH=$(grep "dockerfile_path=" "$GITHUB_OUTPUT" | sed 's/dockerfile_path=//')
    
    if [ -n "$CONTEXT" ] && [ -n "$PLATFORMS" ] && [ -n "$TAG" ] && [ -n "$VERSION" ] && [ -n "$DOCKERFILE_PATH" ]; then
        print_pass "All required outputs are present and non-empty"
        echo "    context: $CONTEXT"
        echo "    platforms: $PLATFORMS"
        echo "    tag: $TAG"
        echo "    version: $VERSION"
        echo "    dockerfile_path: $DOCKERFILE_PATH"
    else
        print_fail "Some outputs are missing or empty"
        return 1
    fi
}

# Main execution
main() {
    echo -e "${BLUE}Testing GitHub Actions Workflow Jobs Locally${NC}"
    echo ""
    
    check_dependencies
    
    test_validate_config_job
    test_filter_changes_job
    test_build_and_push_job
    
    # Summary
    print_header "Test Summary"
    echo -e "${GREEN}Passed: $PASSED${NC}"
    if [ $FAILED -gt 0 ]; then
        echo -e "${RED}Failed: $FAILED${NC}"
        exit 1
    else
        echo -e "${GREEN}All workflow jobs tested successfully!${NC}"
        exit 0
    fi
}

main "$@"
