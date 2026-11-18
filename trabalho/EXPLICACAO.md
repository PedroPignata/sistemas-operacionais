# Como este projeto funciona

## A ideia

Você construiu um pequeno sistema Linux e o executou dentro de uma máquina emulada. Esse sistema tem um kernel com uma modificação específica para a sua matrícula. Ao executar uma chamada de sistema, essa modificação calcula e registra a resposta do trabalho.

O fluxo é:

```text
QEMU inicia a máquina emulada
    -> carrega bzImage (kernel Linux com seu patch)
    -> descompacta initramfs.cpio.gz na memória
    -> executa /init como processo 1
    -> /init monta /proc e /sys e abre o shell do BusyBox
    -> você executa /bin/sysinfo_aluno
    -> sysinfo solicita um serviço ao kernel
    -> o código modificado calcula e registra a solução
    -> dmesg permite consultar essa mensagem
```

## Kernel, BusyBox e initramfs

O **kernel** gerencia CPU, memória, dispositivos e processos. Compilá-lo transforma o código-fonte em uma imagem executável, `bzImage`. Só compilar não muda o kernel em execução: o QEMU precisa iniciar usando essa imagem.

O **BusyBox** reúne muitos comandos em um só executável. Ele fornece o shell e ferramentas como `mount`, `cut`, `dmesg` e `poweroff`. Diversos nomes de comandos são links para o mesmo BusyBox, que escolhe o comportamento pelo nome usado para chamá-lo.

O **initramfs** é o sistema de arquivos inicial. O kernel descompacta o arquivo CPIO na RAM. Ele contém pastas como `/bin`, `/dev`, `/proc` e `/sys`, além de `/init` e do programa C. Neste projeto não é necessário criar um disco virtual.

Os dispositivos especiais em `/dev` não são arquivos de texto: seus números identificam interfaces de dispositivos no kernel. Eles são registrados no arquivo CPIO pela ferramenta `gen_init_cpio`.

## O que faz o init

`init` é o primeiro programa de espaço do usuário, com PID 1. O arquivo começa com `#!/bin/sh`, então é interpretado pelo shell fornecido pelo BusyBox.

Ele monta `/proc`, que expõe informações de processos e do sistema, e `/sys`, que expõe informações sobre dispositivos e outros objetos do kernel. Depois cria o dispositivo do console serial, mostra uma mensagem com o tempo de inicialização e inicia um shell interativo usando `setsid cttyhack sh`.

Quando esse shell termina, o script tenta desligar a máquina emulada com `poweroff -f`. Caso o desligamento retorne, resta um `exec /bin/sh` como alternativa.

## O programa C

`struct sysinfo info` reserva espaço para receber informações. `sysinfo(&info)` fornece o endereço dessa estrutura à função da biblioteca C que faz a chamada de sistema. O kernel preenche a estrutura e devolve o controle ao programa.

Se o retorno for `-1`, houve erro: `perror` imprime a causa e o programa termina com falha. Se der certo, o programa mostra o tempo de atividade, a memória e a quantidade de processos. A memória é multiplicada por `mem_unit` para obter bytes; a conversão para `unsigned long long` ocorre antes da multiplicação.

A biblioteca C está incorporada ao executável pela opção `-static`. Isso é necessário porque o pequeno sistema emulado não contém o carregador dinâmico e as bibliotecas de uma instalação Linux comum.

As linhas impressas pelo programa C vão para o terminal. A solução do trabalho é registrada pelo kernel em seu buffer de mensagens, consultado com `dmesg`. São dois caminhos de saída diferentes.

## O que faz o patch da sua matrícula

O patch original acrescenta código à rotina do kernel que atende `sysinfo` e também uma função auxiliar com preenchimento em código de máquina.

Antes de gerar a solução, ele verifica a identificação do compilador e do linker, a versão da máquina QEMU, características da CPU, o uso de aceleração, a quantidade de memória e o número de CPUs. Se algo estiver incorreto, ele emite `AMBIENTE INCORRETO` com um código.

Com o ambiente correto, ele localiza duas funções do kernel, `generic_access_phys` e `vmalloc_32_user`, e calcula um hash dos bytes dessas funções. Também usa caracteres da versão do kernel e um trecho de instruções de máquina para calcular o resultado. Por isso a resposta depende do patch, da versão do kernel e da compilação. Não basta executar o programa C no Linux normal do computador.

A mensagem final tem o formato `[+] SOLUCAO: <valor hexadecimal>`. Para o campo de resposta, usa-se apenas o valor indicado, sem o prefixo do log nem uma quebra de linha adicional.

## Por que o QEMU tem parâmetros fixos

`-machine pc-i440fx-8.2` escolhe a máquina emulada. `-cpu qemu64` escolhe o processador virtual. `-accel tcg` usa emulação por software. `-smp 1` fornece uma CPU e `-m 256` fornece 256 MB de RAM.

`-kernel` aponta para o kernel compilado e `-initrd` para o arquivo inicial. `-nographic` usa o terminal; `console=ttyS0` direciona o console para a porta serial. `loglevel=3` limita as mensagens exibidas diretamente no console, mas a solução continua acessível pelo `dmesg`.

Esses valores fazem parte das verificações do patch. Alterá-los pode impedir a obtenção da resposta correta.

## Como explicar em sala

“Compilei o Linux 6.6.137 com o patch da minha matrícula e preparei um initramfs com BusyBox e um programa C estático. Iniciei tudo no QEMU com uma CPU e 256 MB de RAM, usando os parâmetros exigidos. Dentro desse Linux, executei o programa, que chamou sysinfo. A rotina modificada do kernel verificou o ambiente, calculou a solução e registrou a mensagem. Consultei essa mensagem com dmesg.”
