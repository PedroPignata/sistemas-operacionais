#!/bin/bash
set -euo pipefail
cd -- "$(dirname -- "$0")"
source ./tools-env.sh
mkdir -p initramfs/{bin,sbin,etc,proc,sys,dev,usr/bin,usr/sbin} output logs
cp -a busybox/_install/. initramfs/
install -m 755 init initramfs/init
install -m 755 sysinfo_aluno initramfs/bin/sysinfo_aluno

# gen_init_cpio grava dispositivos especiais no arquivo sem exigir root.
# O kernel cria esses dispositivos ao descompactar o initramfs no boot.
# Assim, nao e preciso montar um tmpfs nem criar dispositivos no hospedeiro.
python3 scripts/initramfs-list.py initramfs > output/initramfs.list
(cd -P -- linux && make usr/gen_init_cpio) > logs/initramfs-build.log 2>&1
linux/usr/gen_init_cpio output/initramfs.list | gzip -9 > output/initramfs.cpio.gz
python3 scripts/verify-artifacts.py > logs/initramfs-check.log
sha256sum output/bzImage output/initramfs.cpio.gz sysinfo_aluno > output/SHA256SUMS
