# Trabalho Prático 01 — Kernel do Linux

Projeto da matrícula 24101218, seguindo o PDF fornecido da disciplina de Sistemas Operacionais, IDP, 2026/2.

## Resultado verificado

O sistema foi compilado e iniciado no QEMU. O programa C executou `sysinfo`
com sucesso e o log do kernel retornou:

```text
[   13.659875] [+] SOLUCAO: 464F865DDB849984
```

Resposta para o Moodle: `464F865DDB849984`.
Também está em `output/resposta.txt`, com exatamente 16 bytes e sem quebra de linha.
O registro completo está em `logs/qemu-console.log`; não houve mensagem de
ambiente incorreto. Após a coleta, a máquina emulada foi desligada normalmente.

O kernel identifica-se como `6.6.137-dirty`: o sufixo indica que o patch foi
aplicado sobre o código do commit original, sem criar outro commit. Isso é
esperado neste procedimento.

## Executar o sistema pronto

```sh
cd trabalho
./run-qemu.sh
```

Depois de aparecer o prompt `~ #` do sistema emulado (ou `/ #`, conforme a pasta atual):

```sh
uname -r
/bin/sysinfo_aluno
dmesg | grep -E 'SOLUCAO|AMBIENTE INCORRETO'
poweroff -f
```

O valor hexadecimal depois de `[+] SOLUCAO:` é a resposta a ser informada no Moodle, em uma única linha. Se aparecer `AMBIENTE INCORRETO`, não use essa saída como resposta. Para fechar o QEMU pelo teclado: Ctrl+A, depois X.

## Arquivos

- `sysinfo_aluno.c`: programa C que chama `sysinfo` e verifica o retorno.
- `Makefile`: compila o programa estaticamente, sem depender de bibliotecas no sistema emulado.
- `init`: primeiro programa executado pelo kernel; monta `/proc` e `/sys` e inicia o shell.
- `build.sh`: compila BusyBox, aplica o patch, compila o kernel e monta o initramfs.
- `pack-initramfs.sh` e `scripts/initramfs-list.py`: empacotam o sistema de arquivos e os dispositivos especiais.
- `run-qemu.sh`: inicia a máquina com os parâmetros exigidos pelo enunciado.
- `check-tools.sh`: confere a versao exata do QEMU e, na compilacao, GCC e Binutils.
- `output/bzImage`: kernel compilado.
- `output/initramfs.cpio.gz`: sistema de arquivos inicial, contendo BusyBox, init e o programa C.
- `output/resposta.txt`: resposta final, sem quebra de linha.
- `output/SHA256SUMS`: hashes das imagens finais e do programa C.
- `patches/patch-24101218.patch`: patch original da sua branch no repositório do IDP.
- `logs/`: registros de compilação e execução.
- `EXPLICACAO.md`: explicação do funcionamento do projeto.

## Ambiente exigido

| Componente | Versão |
| --- | --- |
| GCC | pacote `13.3.0-6ubuntu2~24.04.1` |
| Binutils | pacote `2.42-4ubuntu2.10` |
| QEMU x86 | pacote `1:8.2.2+ds-0ubuntu1.18` |
| BusyBox | tag `1_36_1`, commit `1a64f6a20aaf6ea4dbba68bbfa8cc1ab7e5c57c4` |
| Linux | tag `v6.6.137`, commit `258cf62a6dfde3c6a39d120a56a298f2ed6a8901` |
| Patch | branch `aluno-24101218` de `idp-edu/so-2026-02-t-01` |

QEMU: `pc-i440fx-8.2`, CPU `qemu64`, aceleração `tcg`, 1 CPU, 256 MB de RAM, console serial e `loglevel=3`.

O kernel usa `x86_64_defconfig`, com as opções de initramfs, 64 bits, devtmpfs e montagem automática conferidas. O único arquivo-fonte alterado é `kernel/sys.c`, pelo patch original. BusyBox usa `defconfig`, com `CONFIG_STATIC=y` e `CONFIG_TC` desativado.

O script de compilação compara a configuração completa com um novo `defconfig`
e o diff completo do kernel com o patch, recusando alterações adicionais em
arquivos rastreados. O empacotamento atualiza `output/SHA256SUMS` automaticamente.
O relatório `REVISAO.md` registra a conferência do PDF e dos prints.
O script `scripts/verify-artifacts.py` verifica o conteúdo do CPIO, incluindo
permissões, proprietários, números dos dispositivos e correspondência dos binários.

Use as versões da tabela no hospedeiro. O script também aceita ferramentas locais em `.tools/root`, se disponíveis. Essa pasta é gerada localmente.

## Recompilar

```sh
./prepare-sources.sh
JOBS=4 ./build.sh
```

Os fontes `linux` e `busybox` são links para `/tmp/idp-so-24101218`, para evitar os espaços no caminho da pasta do projeto, que os Makefiles não suportam. Se o sistema limpar `/tmp`, restaure os fontes com `./prepare-sources.sh` antes de recompilar. As imagens finais em `output/` permitem executar o projeto mesmo sem os fontes.

As ferramentas permanecem em `.tools/` no projeto. `tools-env.sh` recria um
alias em `/tmp/idp-so-24101218-tools` para usá-las por um caminho sem espaços.
Os comandos de compilação também entram na pasta física dos fontes, evitando
que subcomandos do Make interpretem o caminho original incorretamente.

O empacotamento usa `usr/gen_init_cpio`, ferramenta do próprio kernel, para criar os mesmos dispositivos especiais descritos no PDF diretamente dentro do arquivo CPIO, sem exigir `sudo`, `mount` ou `mknod` no hospedeiro. O arquivo `init` mantém o comportamento do PDF, com aspas de shell válidas e `printf` para as mensagens.

Para recompilar, instale também `build-essential`, `libncurses-dev`, `bison`, `flex`, `libssl-dev`, `libelf-dev`, `pahole`, `cpio` e Python 3 no hospedeiro.
