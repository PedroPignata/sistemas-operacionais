#!/bin/bash
set -euo pipefail
cd -- "$(dirname -- "$0")"
source ./tools-env.sh
jobs="${JOBS:-2}"
[[ "$jobs" =~ ^[1-9][0-9]*$ ]] || { echo 'JOBS deve ser um inteiro positivo.' >&2; exit 1; }
mkdir -p logs output
make_kernel() { (cd -P -- linux && make "$@"); }
make_busybox() { (cd -P -- busybox && make "$@"); }

test "$(git -C busybox rev-parse HEAD)" = 1a64f6a20aaf6ea4dbba68bbfa8cc1ab7e5c57c4
test "$(git -C linux rev-parse HEAD)" = 258cf62a6dfde3c6a39d120a56a298f2ed6a8901
./check-tools.sh

if [[ ! -f busybox/.config ]]; then
    make_busybox defconfig > logs/busybox-config.log 2>&1
    sed -i 's/^# CONFIG_STATIC is not set/CONFIG_STATIC=y/; s/^CONFIG_TC=y/# CONFIG_TC is not set/' busybox/.config
    make_busybox oldconfig < /dev/null >> logs/busybox-config.log 2>&1
fi
grep -qx 'CONFIG_STATIC=y' busybox/.config
grep -qx '# CONFIG_TC is not set' busybox/.config
make_busybox -j"$jobs" > logs/busybox-build.log 2>&1
make_busybox install >> logs/busybox-build.log 2>&1

patch_file="$PWD/patches/patch-24101218.patch"
if git -C linux apply --check "$patch_file" 2>/dev/null; then
    git -C linux apply "$patch_file"
else
    git -C linux apply --reverse --check "$patch_file"
fi
# Confere o diff completo: nenhuma outra alteracao em arquivos rastreados.
cmp <(git -C linux diff --no-ext-diff HEAD | sed '/^index /d') \
    <(sed '/^index /d' "$patch_file")
if [[ ! -f linux/.config ]]; then
    make_kernel defconfig > logs/kernel-config.log 2>&1
fi
for option in BLK_DEV_INITRD 64BIT DEVTMPFS DEVTMPFS_MOUNT; do
    grep -qx "CONFIG_${option}=y" linux/.config
done
# O PDF exige o defconfig inteiro, sem ajustes adicionais.
reference_config="$(mktemp /tmp/idp-so-config.XXXXXX)"
trap 'rm -f -- "$reference_config" "$reference_config.old"' EXIT
make_kernel KCONFIG_CONFIG="$reference_config" defconfig > logs/kernel-config-check.log 2>&1
if ! cmp -s "$reference_config" linux/.config; then
    echo 'A configuracao do kernel difere do defconfig exigido pelo PDF.' >&2
    exit 1
fi
make_kernel -j"$jobs" bzImage > logs/kernel-build.log 2>&1
cp linux/arch/x86/boot/bzImage output/bzImage
make -B sysinfo_aluno > logs/programa-build.log 2>&1
./pack-initramfs.sh
printf 'Compilacao concluida. Execute ./run-qemu.sh\n'
