.intel_syntax noprefix
.code16
.section .text
.global _start

.equ HEADER, 0x7e00
.equ TABLE, HEADER + 0x172
.equ BUFFER, 0x8000
.equ STACK_SEG, 0x8700
.equ STACK_PTR, 0x6eb0

_start:
    cli
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7c00
    cld
    mov [drive], dl
    sti

    # Reinicia o drive de boot e le o cabecalho no LBA 1.
    push ds
    int 0x13
    pop ds
    jc disk_error
    xor ax, ax
    mov es, ax
    mov ax, 1
    mov bx, HEADER
    call read_sector
    movzx bp, byte ptr [TABLE]
    test bp, bp
    jz disk_error
    cmp bp, (512 - 0x172 - 5) / 4
    ja disk_error
    mov si, TABLE + 5

next_piece:
    # Ficha 24101218: LBA (2 bytes), destino (1), quantidade (1).
    mov ax, [si]
    movzx di, byte ptr [si + 2]
    movzx cx, byte ptr [si + 3]
    test cx, cx
    jz disk_error
    mov dx, di
    add dx, cx
    cmp dx, 256
    ja disk_error
    # Cada setor de 512 bytes avanca 32 paragrafos de 16 bytes.
    shl di, 5
    add di, [TABLE + 1]
    add si, 4

next_sector:
    # O buffer fixo e alinhado evita cruzar uma fronteira de DMA de 64 KiB.
    mov bx, BUFFER
    call read_sector
    push si
    push di
    push cx
    mov es, di
    xor di, di
    mov si, BUFFER
    mov cx, 256
    cld
    rep movsw
    pop cx
    pop di
    pop si
    inc ax
    add di, 32
    loop next_sector

    dec bp
    jnz next_piece

    # RETF consome os dois PUSH, deixando a pilha no valor da ficha.
    mov di, [TABLE + 3]
    mov dl, [drive]
    cli
    mov ax, STACK_SEG
    mov ss, ax
    mov sp, STACK_PTR
    push word ptr [TABLE + 1]
    push 0
    sti
    retf

# Le um setor de AX (LBA) para 0000:BX, preservando os registradores.
read_sector:
    cmp ax, 2880
    jae disk_error
    pusha
    push ds
    push es
    xor dx, dx
    mov es, dx
    mov cx, 18
    div cx
    mov cl, dl
    inc cl
    shr ax, 1                  # cilindro; CF recebe a cabeca
    mov ch, al
    setc dh
    mov dl, [drive]
    mov ax, 0x0201
    int 0x13
    pop es
    pop ds
    popa
    jc disk_error
    ret

disk_error:
    cld
    mov si, offset error_message
    mov bx, 0x0007
print_error:
    lodsb
    test al, al
    jz stop
    mov ah, 0x0e
    int 0x10
    jmp print_error
stop:
    cli
    hlt
    jmp stop

drive: .byte 0
error_message: .asciz "Erro de leitura ou cabecalho"
.org 510
.word 0xaa55
