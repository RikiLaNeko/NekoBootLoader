#!/usr/bin/env bash
# Exit immediately if a command exits with a non-zero status.
set -e

echo "Cleaning up build artifacts..."

# Remove common build artifacts recursively
find . -name "*.bin" -delete
find . -name "*.com" -delete
find . -name "*.img" -delete
find . -name "*.log" -delete

echo "Cleanup complete."
