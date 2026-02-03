# How to Trigger Image Builds

## Automatic Trigger

The workflow automatically triggers when you push changes to the `main` branch that affect files in the `images/` directory.

## Trigger Build for savant-deepstream

To trigger a build for `savant-deepstream` (or any specific image), you need to make a change to files in that image's directory and push to main:

### Method 1: Update config.yaml (Recommended)

```bash
# Make a small change to trigger rebuild (e.g., add a comment)
cd images/savant-deepstream
# Edit config.yaml - add a comment or update version
git add config.yaml
git commit -m "Trigger build for savant-deepstream"
git push origin main
```

### Method 2: Touch the config file

```bash
# Simply touch the file to trigger a rebuild
touch images/savant-deepstream/config.yaml
git add images/savant-deepstream/config.yaml
git commit -m "Trigger build for savant-deepstream"
git push origin main
```

### Method 3: Add a comment to config.yaml

You can add a comment to the config file:

```yaml
platforms: [linux/amd64,linux/arm64]
context: images/savant-deepstream
tag: savant-deepstream
# Build triggered: 2025-01-XX
versions:
  "latest":
    dockerfile: |
      FROM ghcr.io/insight-platform/savant-deepstream:latest
```

## What Triggers a Build?

The workflow detects changes in:
- `images/<image-name>/config.yaml` - The config file
- Any files in `images/<image-name>/` directory
- `images/<image-name>/Dockerfile` (if it exists as a separate file)

## Workflow Process

1. **validate-config**: Validates all image configs
2. **filter-changes**: Detects which images changed and expands them into a build matrix
3. **build-and-push**: Builds and pushes only the changed images

## Check What Will Be Built

Before pushing, you can check what images will be detected as changed:

```bash
# Compare with previous commit
bash scripts/detect-changes.sh HEAD~1 HEAD

# Or compare with a specific commit
bash scripts/detect-changes.sh <commit-sha> HEAD
```

This will show you which images will be built in the workflow.

## Manual Workflow Trigger (if configured)

If you want to add manual workflow dispatch, you would need to add this to the workflow:

```yaml
on:
  push:
    branches:
      - main
    paths:
      - 'images/**'
      - '.github/workflows/build-images.yml'
  workflow_dispatch:
    inputs:
      image_name:
        description: 'Image name to build (leave empty for all changed)'
        required: false
        type: string
```

Then you can trigger it manually from GitHub Actions UI.
