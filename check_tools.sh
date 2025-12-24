#!/bin/bash

# Define a list of programs you want to check
programs=("nvim" "git" "node" "python3" "docker")

echo "--- Tool Version Check ---"

for tool in "${programs[@]}"; do
  # Check if the tool exists on the system
  if command -v "$tool" &> /dev/null; then
    # Get the first line of the version output
    # (Using 'head -n 1' because some tools output a lot of text)
    version=$($tool --version 2>&1 | head -n 1)
    echo "✅ $tool: $version"
  else
    echo "❌ $tool: Not found"
  fi
done

echo "--------------------------"
