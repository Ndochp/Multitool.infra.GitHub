#!/bin/bash

# Check if the repository parameter is provided
if [ -z "$1" ]; then
  echo "Usage: $0 <repository-url>"
  exit 1
fi

REPO_URL=$1

# Create a directory for the runner
RUNNER_DIR="local-runner"
mkdir -p $RUNNER_DIR
cd $RUNNER_DIR

# Download the GitHub Actions runner
echo "Downloading the GitHub Actions runner..."
curl -o actions-runner-linux-x64.tar.gz -L https://github.com/actions/runner/releases/latest/download/actions-runner-linux-x64.tar.gz
tar xzf ./actions-runner-linux-x64.tar.gz

# Configure the runner
echo "Configuring the runner..."
./config.sh --url $REPO_URL --token YOUR_RUNNER_TOKEN

# Run the runner
echo "Starting the runner..."
./run.sh

# Note: Replace YOUR_RUNNER_TOKEN with a valid token for the repository.