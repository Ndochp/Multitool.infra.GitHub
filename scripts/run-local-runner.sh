#!/bin/bash
# Setup and register a GitHub Actions self-hosted runner (Linux/macOS).
# Requires GITHUB_PAT in environment (Personal Access Token with repo scope)
# to obtain the registration token. Optionally pass repository URL as first argument.
#
# Usage:
#   export GITHUB_PAT=ghp_xxxx
#   ./run-local-runner.sh [repository-url]
#
# Default repository: https://github.com/ndochp/Multitool.infra.GitHub

set -e

REPO_URL="${1:-https://github.com/ndochp/Multitool.infra.GitHub}"
RUNNER_DIR="${RUNNER_DIR:-actions-runner}"
RUNNER_NAME="${RUNNER_NAME:-local-runner}"
LABELS="${RUNNER_LABELS:-self-hosted,linux,x64}"

if [ -z "$GITHUB_PAT" ]; then
  echo "Error: GITHUB_PAT is not set. Set it to a Personal Access Token (repo scope) to get the registration token."
  echo "Example: export GITHUB_PAT=ghp_xxxx"
  exit 1
fi

echo "Setting up GitHub Actions runner for $REPO_URL"
mkdir -p "$RUNNER_DIR"
cd "$RUNNER_DIR"

if [ ! -f ./config.sh ]; then
  echo "Downloading latest GitHub Actions runner..."
  runner_version=$(curl -sSf https://api.github.com/repos/actions/runner/releases/latest | grep '"tag_name":' | sed -E 's/.*"v([^"]+)".*/\1/')
  curl -sSfL -o actions-runner-linux-x64.tar.gz "https://github.com/actions/runner/releases/download/v${runner_version}/actions-runner-linux-x64-${runner_version}.tar.gz"
  tar xzf actions-runner-linux-x64.tar.gz
fi

api_url="${REPO_URL/https:\/\/github.com/https://api.github.com/repos}"
api_url="${api_url%.git}"
reg_token=$(curl -sSf -X POST -H "Authorization: token $GITHUB_PAT" "${api_url}/actions/runners/registration-token" | grep -o '"token":"[^"]*"' | cut -d'"' -f4)

if [ -z "$reg_token" ]; then
  echo "Error: Failed to get registration token. Check GITHUB_PAT and repository access."
  exit 1
fi

./config.sh --url "$REPO_URL" --token "$reg_token" --name "$RUNNER_NAME" --labels "$LABELS" --unattended

echo "Starting the runner..."
./run.sh
