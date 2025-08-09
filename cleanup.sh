#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero status.
set -e

echo "Cleaning up build artifacts..."
rm -f boot1.bin boot2.bin boot_x86.com os.img qemu.log
echo "Cleanup complete."
