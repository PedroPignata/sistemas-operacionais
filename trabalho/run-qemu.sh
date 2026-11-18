#!/bin/bash
set -euo pipefail
cd -- "$(dirname -- "$0")"
source ./tools-env.sh
./check-tools.sh --runtime
exec qemu-system-x86_64 -machine pc-i440fx-8.2 -cpu qemu64 -accel tcg \
    -smp 1 -m 256 -nographic -no-reboot \
    -kernel output/bzImage -initrd output/initramfs.cpio.gz \
    -append 'console=ttyS0 loglevel=3'
