#!/usr/bin/env bash

set -e

echo "Assembling 16-bit bootloader..."
nasm -f bin boot_x86.asm -o boot_x86.com

echo "Booting boot_x86.com with QEMU..."
qemu-system-x86_64 -fda boot_x86.com
