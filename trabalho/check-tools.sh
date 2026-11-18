#!/bin/bash
set -euo pipefail
cd -- "$(dirname -- "$0")"
source ./tools-env.sh
qemu_version="$(qemu-system-x86_64 --version)"
expected='QEMU emulator version 8.2.2 (Debian 1:8.2.2+ds-0ubuntu1.18)'
if [[ "${qemu_version%%$'\n'*}" != "$expected" ]]; then
    printf 'QEMU diferente da versao exigida: %s\n' "$qemu_version" >&2
    exit 1
fi
if [[ "${1:-}" == '--runtime' ]]; then
    exit 0
fi
test "$(dpkg-query -W -f='${Version}' gcc-13)" = '13.3.0-6ubuntu2~24.04.1'
test "$(dpkg-query -W -f='${Version}' binutils)" = '2.42-4ubuntu2.10'
gcc_version="$(gcc --version)"
test "${gcc_version%%$'\n'*}" = 'gcc (Ubuntu 13.3.0-6ubuntu2~24.04.1) 13.3.0'
ld_version="$(ld --version)"
test "${ld_version%%$'\n'*}" = 'GNU ld (GNU Binutils for Ubuntu) 2.42'
