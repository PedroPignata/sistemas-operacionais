# Trabalho Prático 02 — Bootloader

Matrícula 24101218. O bootloader inicializa um sistema simples em modo real x86 a partir de um disquete virtual.

## Entrega

- Questão 1: `6141E114FA02FF72`, em uma linha, sem o prefixo `RESPOSTA:`.
- A entrega original da questão 2 usa somente `bootloader.s` em um ZIP com a matrícula e o MD5 no nome.

O log `teste-qemu.txt` registra dois boots bem-sucedidos: o disco da matrícula e uma cópia de teste com os fragmentos removidos dos locais originais, movidos e reordenados. A cópia força leituras que atravessam trilhas e cilindros. O disco original está em `material/`.

## Compilar e rodar

Na pasta deste README:

```sh
as -o bootloader.o bootloader.s
ld -o bootloader --oformat binary -Ttext 0x7c00 bootloader.o
cp material/disco-24101218.img teste.img
dd if=bootloader of=teste.img conv=notrunc bs=512 count=1
qemu-system-x86_64 -drive file=teste.img,format=raw,if=floppy -boot a
```

Use QEMU 8.2.2 ou superior. A imagem `teste.img` já está pronta para execução.

## Como funciona

1. A BIOS carrega os 512 bytes do primeiro setor em `0x7C00`. O bootloader inicializa os segmentos e salva o identificador do drive fornecido em `DL`.
2. O bootloader lê o LBA 1 em `0x7E00`. Na posição `0x172` do setor, lê a contagem de fragmentos, o segmento do kernel, o valor de confirmação e a tabela de fragmentos.
3. Cada entrada indica o LBA inicial, o setor de destino no kernel e a quantidade de setores. A rotina converte LBA para cilindro, cabeça e setor (CHS), e chama a BIOS uma vez por setor. O setor passa por um buffer alinhado e é copiado para o destino em memória.
4. O bootloader coloca a confirmação em `DI`, restaura `DL` e configura a pilha em `8700:6EB0`, conforme a ficha. O salto longo por `retf` entrega o controle ao kernel em `SEGMENTO:0000` com a pilha no valor exigido.
5. O kernel valida a entrega e mostra a resposta no console. A assinatura `55 AA` ocupa os dois últimos bytes do setor de boot.
