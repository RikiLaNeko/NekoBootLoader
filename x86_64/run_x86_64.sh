#!/usr/bin/env bash
set -e

echo "[*] Assembling..."
nasm -f bin boot1.asm -o boot1.bin
nasm -f bin boot2.asm -o boot2.bin

echo "[*] Creating disk image..."
dd if=/dev/zero bs=512 count=2880 of=os.img
dd if=boot1.bin of=os.img bs=512 count=1 conv=notrunc
dd if=boot2.bin of=os.img bs=512 seek=1 conv=notrunc

echo "[*] Booting in QEMU with debugging..."
qemu-system-x86_64 -drive format=raw,file=os.img -cpu qemu64 -m 128M -serial stdio -d int,cpu_reset -D qemu.log
