#!/usr/bin/env python3
"""Confere o CPIO efetivamente gerado, sem extrair dispositivos no host."""
import gzip
import stat
from pathlib import Path

root = Path(__file__).resolve().parents[1]
data = gzip.decompress((root / 'output/initramfs.cpio.gz').read_bytes())
entries = {}
offset = 0
while True:
    header = data[offset:offset + 110]
    assert header[:6] == b'070701', 'Formato CPIO diferente de newc'
    fields = [int(header[i:i + 8], 16) for i in range(6, 110, 8)]
    _, mode, uid, gid, _, _, size, _, _, major, minor, namesize, _ = fields
    offset += 110
    name = data[offset:offset + namesize - 1].decode()
    offset = (offset + namesize + 3) & ~3
    payload = data[offset:offset + size]
    offset = (offset + size + 3) & ~3
    if name == 'TRAILER!!!':
        break
    name = '/' + name.removeprefix('./').lstrip('/')
    assert name not in entries, f'Entrada duplicada: {name}'
    entries[name] = (mode, uid, gid, major, minor, payload)

for name in ('bin', 'sbin', 'etc', 'proc', 'sys', 'dev', 'usr/bin', 'usr/sbin'):
    assert stat.S_ISDIR(entries['/' + name][0]), name
for name, source in [('/init', 'init'), ('/bin/sysinfo_aluno', 'sysinfo_aluno'),
                     ('/bin/busybox', 'initramfs/bin/busybox')]:
    mode, uid, _, _, _, payload = entries[name]
    assert stat.S_ISREG(mode) and mode & 0o111 and uid == 0, name
    assert payload == (root / source).read_bytes(), name
assert stat.S_ISLNK(entries['/bin/sh'][0])
assert entries['/bin/sh'][-1].rstrip(b'\0') == b'busybox'
assert '/sbin/tc' not in entries
for name, mode, major, minor, group in [
    ('console', 0o622, 5, 1, 5), ('null', 0o666, 1, 3, 0),
    ('zero', 0o666, 1, 5, 0), ('ptmx', 0o666, 5, 2, 5),
    ('tty', 0o666, 5, 0, 5), ('random', 0o444, 1, 8, 0),
    ('urandom', 0o444, 1, 9, 0),
]:
    actual, uid, gid, actual_major, actual_minor, _ = entries['/dev/' + name]
    assert stat.S_ISCHR(actual) and stat.S_IMODE(actual) == mode, name
    assert (uid, gid, actual_major, actual_minor) == (0, group, major, minor), name
print(f'CPIO newc: {len(entries)} entradas; diretorios, binarios, init e dispositivos OK.')
