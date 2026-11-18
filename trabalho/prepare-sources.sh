#!/bin/bash
set -euo pipefail
cd -- "$(dirname -- "$0")"
so_cache="/tmp/idp-so-24101218"
mkdir -p "$so_cache"
for component in busybox linux; do
    if [[ ! -e "$so_cache/$component" ]]; then
        case "$component" in
            busybox) git clone --depth 1 --branch 1_36_1 https://github.com/mirror/busybox.git "$so_cache/busybox" ;;
            linux) git clone --depth 1 --branch v6.6.137 https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable.git "$so_cache/linux" ;;
        esac
    fi
    if [[ -L "$component" && ! -e "$component" ]]; then
        unlink "$component"
    fi
    if [[ ! -e "$component" ]]; then
        ln -s "$so_cache/$component" "$component"
    fi
done
