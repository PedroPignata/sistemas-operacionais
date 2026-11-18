# Revisão integral — 05/11/2026

Foram relidos os textos das oito páginas do PDF fornecido, conferidas as oito páginas renderizadas e reexaminados os três prints. O código, os scripts, os arquivos gerados, a configuração completa e a execução foram comparados com os requisitos.

## Conferência do enunciado

| Parte | Conferência e resultado |
| --- | --- |
| 1 e 2 — objetivo e ambiente | Linux modificado compilado e inicializado em QEMU. O PDF permite outro computador com as versões especificadas. Hospedeiro Linux Mint baseado em Ubuntu Noble; versões obrigatórias reproduzidas. |
| 2.1 — ferramentas | GCC `13.3.0-6ubuntu2~24.04.1`, Binutils `2.42-4ubuntu2.10` e QEMU `1:8.2.2+ds-0ubuntu1.18` conferidos. As ferramentas ausentes foram extraídas dos pacotes oficiais no projeto. As ferramentas auxiliares de compilação foram usadas com sucesso. Não foi feita atualização geral que pudesse mudar as versões fixadas. |
| 2.2 — QEMU | QEMU 8.2.2; máquina `pc-i440fx-8.2` disponível. |
| 2.3 — BusyBox | Commit `1a64f6a20aaf6ea4dbba68bbfa8cc1ab7e5c57c4`, fontes sem alterações rastreadas, versão 1.36.1 confirmada dentro do sistema emulado. Binário estático; TC desativado. As opções foram configuradas por defconfig/oldconfig, sem interação pelo menu. |
| 2.4 — kernel | Commit `258cf62a6dfde3c6a39d120a56a298f2ed6a8901`, Linux 6.6.137. Configuração inteira idêntica a uma nova execução de `make defconfig`; quatro opções obrigatórias habilitadas. Conferência automatizada em vez de interação pelo menu. |
| 2.4.1 — assinaturas | Os comandos opcionais de chaves não foram necessários. Não se alterou a configuração padrão. |
| 2.4.2 — patch | Branch `aluno-24101218`. Diff completo dos arquivos rastreados corresponde ao patch original, desconsiderando apenas o comprimento de exibição dos hashes na linha `index`. Somente `kernel/sys.c` alterado. |
| 2.5 — sistema em RAM | Diretórios exigidos presentes; arquivos do BusyBox e programa C incluídos. |
| 2.5.1 — init | Executável, monta proc e sysfs, cria ttyS0, mostra tempo de boot, inicia shell e permite desligar. `printf` substitui as mensagens com echo; aspas tipográficas do PDF foram convertidas em aspas válidas. |
| 2.5.2 — dispositivos | Os sete dispositivos do PDF têm tipos, permissões, UID/GID e números major/minor corretos no CPIO. Conferidos também dentro do sistema emulado. |
| 2.6 — empacotamento | CPIO newc comprimido com gzip -9, fora da árvore initramfs. Usou-se `usr/gen_init_cpio`, do próprio kernel, em lugar de criar dispositivos com root e empacotar com find/cpio. O formato e os dispositivos resultantes foram conferidos diretamente no arquivo. |
| 2.7 — execução | Parâmetros iguais aos do PDF: pc-i440fx-8.2, qemu64, TCG, 1 CPU, 256 MB, nographic, no-reboot e `console=ttyS0 loglevel=3`. |
| 2.8 — syscall | Programa C estático executado no convidado; retorno 0; solução obtida por dmesg. |
| 2.9 a 2.13 — entrega | Entrega individual, apenas a resposta final via Moodle. Prazo indicado: 08/11/2026, 23:55. Nenhuma submissão ou verificação no Moodle foi feita nesta revisão. |
| 2.14 — recursos | O PDF recomenda pelo menos 15 GB livres para a construção. Foram usados clones rasos e a compilação foi concluída com o espaço disponível. Isso não dispensa conferir espaço antes de reconstruções futuras. |
| 3 — bibliografia | Referências de apoio presentes; não acrescentam outro artefato obrigatório de entrega. |

## Conferência dos prints

Os três prints correspondem ao Trabalho Prático 01 — Kernel do Linux. A página mostra uma tentativa em andamento e somente uma tentativa permitida. O enunciado pede uma string em uma única linha e informa penalização de 10% por verificação a partir da segunda submissão incorreta.

Há uma divergência de nomenclatura: o link no print cita `trabalho-so-02-2026-02.pdf`, enquanto o arquivo enviado é `trabalho-so-01-2026-02.pdf` e seu título é Trabalho Prático 01. A revisão segue o PDF efetivamente enviado. O texto genérico do print fala em letras maiúsculas, enquanto o PDF especifica um número hexadecimal. A saída real do kernel fornece o hexadecimal em maiúsculas; não se deve remover seus dígitos.

## Correções realizadas

- Conferência da versão exata do QEMU antes de executar e de GCC/LD antes de compilar; antes havia apenas conferências parciais.
- Comparação automática da configuração inteira com defconfig e do diff do kernel com o patch.
- Empacotador carrega seu próprio ambiente e cria a pasta de logs, permitindo chamada independente.
- Hashes atualizados automaticamente após empacotar, evitando manifesto antigo após recompilação.
- Validação direta das 420 entradas do CPIO, incluindo dispositivos, links, init e binários.
- Compilação entra nas pastas físicas dos fontes: corrigidas mensagens de `cd` que ainda apareciam em subcomandos por causa do PWD com espaços.
- Caminho sem espaços para as ferramentas por alias temporário; pacotes continuam persistidos no projeto.
- Instruções de prompt e consulta ao dmesg corrigidas para mostrar também possíveis erros de ambiente.

A compilação original registrou um warning de objtool sobre uma instrução inalcançável na rotina modificada pelo patch. O PDF prevê warnings. O patch original foi mantido; não houve erro de compilação, e a rotina passou no teste real.

## Validação final

Recompilação concluída. Scripts verificados com bash/sh, manifesto SHA-256 conferido, gzip e conteúdo newc validados. Uma nova inicialização no QEMU confirmou:

```text
Linux: 6.6.137-dirty
BusyBox: 1.36.1
Linha de comando: console=ttyS0 loglevel=3
STATUS_SYSINFO=0
[   17.481947] [+] SOLUCAO: 464F865DDB849984
```

Não houve mensagem de ambiente incorreto; a máquina desligou com `poweroff -f`. A resposta repetiu o valor da execução anterior. O sufixo `-dirty` indica a aplicação do patch na árvore Git, como esperado.

Evidência: `logs/qemu-console-revisao.log`. Resposta: `output/resposta.txt`, 16 caracteres, sem espaço, BOM ou quebra de linha. Este resultado foi validado localmente; a aceitação pelo corretor do Moodle não foi testada.
