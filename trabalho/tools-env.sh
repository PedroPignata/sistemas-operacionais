#!/bin/bash
# Este arquivo deve ser carregado com: source ./tools-env.sh
SO_PROJECT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
[[ -d "$SO_PROJECT_DIR/.tools/root" ]] || return 0
# Alguns Makefiles tambem interpretam caminhos de ferramentas sem aspas.
# Os pacotes ficam no projeto; apenas este alias descartavel fica em /tmp.
SO_TOOLS_ALIAS=/tmp/idp-so-24101218-tools
if [[ ! -e "$SO_TOOLS_ALIAS" && ! -L "$SO_TOOLS_ALIAS" ]]; then
    ln -s "$SO_PROJECT_DIR/.tools" "$SO_TOOLS_ALIAS"
fi
if [[ ! -L "$SO_TOOLS_ALIAS" || "$(readlink "$SO_TOOLS_ALIAS")" != "$SO_PROJECT_DIR/.tools" ]]; then
    printf 'Alias de ferramentas em uso por outro diretorio: %s\n' "$SO_TOOLS_ALIAS" >&2
    return 1
fi
SO_LOCAL_ROOT="$SO_TOOLS_ALIAS/root"
export PATH="$SO_LOCAL_ROOT/usr/bin:$PATH"
export BISON_PKGDATADIR="$SO_LOCAL_ROOT/usr/share/bison"
export M4="$SO_LOCAL_ROOT/usr/bin/m4"
export C_INCLUDE_PATH="$SO_LOCAL_ROOT/usr/include:$SO_LOCAL_ROOT/usr/include/x86_64-linux-gnu${C_INCLUDE_PATH:+:$C_INCLUDE_PATH}"
export LIBRARY_PATH="$SO_LOCAL_ROOT/usr/lib/x86_64-linux-gnu${LIBRARY_PATH:+:$LIBRARY_PATH}"
