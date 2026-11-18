#!/usr/bin/env python3
"""Gera a lista do utilitario oficial usr/gen_init_cpio do kernel."""
import os
import stat
import sys
from pathlib import Path

root = Path(sys.argv[1]).resolve()
for entry in sorted(root.rglob('*')):
    name = '/' + entry.relative_to(root).as_posix()
    mode = stat.S_IMODE(entry.lstat().st_mode)
    if entry.is_symlink():
        print(f'slink {name} {os.readlink(entry)} {mode:o} 0 0')
    elif entry.is_dir():
        print(f'dir {name} {mode:o} 0 0')
    elif entry.is_file():
        # gen_init_cpio aceita um caminho de arquivo sem espacos. A fonte e
        # relativa a raiz do projeto para funcionar neste workspace.
        source = entry.relative_to(Path.cwd()).as_posix()
        print(f'file {name} {source} {mode:o} 0 0')
for name, mode, major, minor, group in [
    ('console', 0o622, 5, 1, 5), ('null', 0o666, 1, 3, 0),
    ('zero', 0o666, 1, 5, 0), ('ptmx', 0o666, 5, 2, 5),
    ('tty', 0o666, 5, 0, 5), ('random', 0o444, 1, 8, 0),
    ('urandom', 0o444, 1, 9, 0),
]:
    print(f'nod /dev/{name} {mode:o} 0 {group} c {major} {minor}')
