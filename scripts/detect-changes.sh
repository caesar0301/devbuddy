#!/bin/bash

# Script to detect changes in image modules and determine which images need to be rebuilt
# Usage: ./scripts/detect-changes.sh [base_commit] [target_commit]
# If no commits provided, defaults to comparing HEAD~1 with HEAD

set -e

# Default to comparing HEAD~1 with HEAD if no arguments provided
BASE_COMMIT=${1:-HEAD~1}
TARGET_COMMIT=${2:-HEAD}

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

# Function to validate YAML file
validate_yaml() {
    local file=$1
    if command -v yq >/dev/null 2>&1; then
        if ! yq e '.' "$file" >/dev/null 2>&1; then
            print_status $RED "Error: Invalid YAML syntax in $file"
            return 1
        fi
    else
        # Fallback to python if yq is not available
        if ! python3 -c "import yaml; yaml.safe_load(open('$file'))" >/dev/null 2>&1; then
            print_status $RED "Error: Invalid YAML syntax in $file"
            return 1
        fi
    fi
    return 0
}

# Function to validate image config
validate_image_config() {
    local config_file=$1
    local image_name=$2
    
    if [ ! -f "$config_file" ]; then
        print_status $RED "Error: Config file not found: $config_file"
        return 1
    fi
    
    if ! validate_yaml "$config_file"; then
        return 1
    fi
    
    # Check required fields using yq or python
    local required_fields=("platforms" "context" "tag")
    for field in "${required_fields[@]}"; do
        if command -v yq >/dev/null 2>&1; then
            if ! yq e ".$field" "$config_file" >/dev/null 2>&1; then
                print_status $RED "Error: Missing required field '$field' in $config_file"
                return 1
            fi
        else
            # Fallback to python
            if ! python3 -c "
import yaml
with open('$config_file') as f:
    config = yaml.safe_load(f)
    if '$field' not in config:
        exit(1)
" >/dev/null 2>&1; then
                print_status $RED "Error: Missing required field '$field' in $config_file"
                return 1
            fi
        fi
    done
    
    # Multi-version format is required
    if command -v yq >/dev/null 2>&1; then
        HAS_VERSIONS=$(yq e '.versions // null' "$config_file")
        if [ "$HAS_VERSIONS" == "null" ] || [ -z "$HAS_VERSIONS" ]; then
            print_status $RED "Error: Config must use multi-version format with 'versions' field in $config_file"
            return 1
        fi
    else
        # Fallback to python
        if ! python3 -c "
import yaml
with open('$config_file') as f:
    config = yaml.safe_load(f)
    if 'versions' not in config or not config.get('versions'):
        exit(1)
" >/dev/null 2>&1; then
            print_status $RED "Error: Config must use multi-version format with 'versions' field in $config_file"
            return 1
        fi
    fi
    
    return 0
}

# Function to get image config value
get_config_value() {
    local config_file=$1
    local key=$2
    
    if command -v yq >/dev/null 2>&1; then
        yq e ".$key" "$config_file"
    else
        # Fallback to python
        python3 -c "
import yaml
with open('$config_file') as f:
    config = yaml.safe_load(f)
    print(config.get('$key', ''))
"
    fi
}

# Function to check if a path has changes
has_changes() {
    local path=$1
    if git diff --name-only "$BASE_COMMIT" "$TARGET_COMMIT" | grep -q "^$path"; then
        return 0
    fi
    return 1
}

# Function to check if a directory has changes
has_directory_changes() {
    local dir=$1
    if git diff --name-only "$BASE_COMMIT" "$TARGET_COMMIT" | grep -q "^$dir/"; then
        return 0
    fi
    return 1
}

# Main execution
main() {
    print_status $BLUE "Detecting changes between $BASE_COMMIT and $TARGET_COMMIT"
    echo
    
    # Check if we're in a git repository
    if ! git rev-parse --git-dir >/dev/null 2>&1; then
        print_status $RED "Error: Not in a git repository"
        exit 1
    fi
    
    # Validate commits exist
    if ! git rev-parse --verify "$BASE_COMMIT" >/dev/null 2>&1; then
        print_status $RED "Error: Base commit '$BASE_COMMIT' does not exist"
        exit 1
    fi
    
    if ! git rev-parse --verify "$TARGET_COMMIT" >/dev/null 2>&1; then
        print_status $RED "Error: Target commit '$TARGET_COMMIT' does not exist"
        exit 1
    fi
    
    # Find all image directories
    local image_dirs=()
    for dir in images/*/; do
        if [ -d "$dir" ] && [ -f "${dir}config.yaml" ]; then
            image_name=$(basename "$dir")
            image_dirs+=("$image_name")
        fi
    done
    
    if [ ${#image_dirs[@]} -eq 0 ]; then
        print_status $YELLOW "No image modules found"
        exit 0
    fi
    
    print_status $BLUE "Found ${#image_dirs[@]} image modules:"
    printf "  %s\n" "${image_dirs[@]}"
    echo
    
    # Check for changes in each image module
    local changed_images=()
    local failed_validations=()
    
    for image_name in "${image_dirs[@]}"; do
        local config_file="images/$image_name/config.yaml"
        local image_dir="images/$image_name"
        
        print_status $BLUE "Checking $image_name..."
        
        # Validate config file
        if ! validate_image_config "$config_file" "$image_name"; then
            failed_validations+=("$image_name")
            continue
        fi
        
        # Check for changes
        local has_changes=false
        
        # Check if config file changed
        if has_changes "$config_file"; then
            print_status $YELLOW "  - Config file changed"
            has_changes=true
        fi
        
        # Check if any files in the image directory changed
        if has_directory_changes "$image_dir"; then
            print_status $YELLOW "  - Files in directory changed"
            has_changes=true
        fi
        
        # Check if Dockerfile changed (if it's a separate file)
        local dockerfile_spec=$(get_config_value "$config_file" "dockerfile")
        if [[ "$dockerfile_spec" == images/* ]] && has_changes "$dockerfile_spec"; then
            print_status $YELLOW "  - Dockerfile changed"
            has_changes=true
        fi
        
        if [ "$has_changes" = true ]; then
            print_status $GREEN "  ✓ $image_name has changes"
            changed_images+=("$image_name")
        else
            print_status $BLUE "  - No changes detected"
        fi
        
        echo
    done
    
    # Report results
    if [ ${#failed_validations[@]} -gt 0 ]; then
        print_status $RED "Validation failed for: ${failed_validations[*]}"
        echo
    fi
    
    if [ ${#changed_images[@]} -eq 0 ]; then
        print_status $GREEN "No changes detected in any image modules"
        echo "[]" > changed_images.json
    else
        print_status $GREEN "Changed images: ${changed_images[*]}"
        
        # Create JSON output for CI
        local json_array="["
        for img in "${changed_images[@]}"; do
            json_array="$json_array\"$img\","
        done
        json_array="${json_array%,}]"
        echo "$json_array" > changed_images.json
        
        # Also output as space-separated list
        echo "${changed_images[*]}" > changed_images.txt
    fi
    
    # Output summary for CI
    echo "changed_count=${#changed_images[@]}" >> $GITHUB_OUTPUT
    echo "changed_images=${changed_images[*]}" >> $GITHUB_OUTPUT
    
    print_status $BLUE "Results saved to:"
    echo "  - changed_images.json (JSON array)"
    echo "  - changed_images.txt (space-separated list)"
    echo "  - GitHub output variables"
}

# Run main function
main "$@" 