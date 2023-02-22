[bits 16]

%define DLAB 0x80

%define IER 1
%define FCR 2
%define LCR 3
%define MCR 4
%define DLL 0
%define DLH 1

%define COM0 0x3F8

section .text start=0

start:
    mov ax, cs
    mov ds, ax
    mov ss, ax
    mov es, ax
    mov ax, 0x7C0
    mov ss, ax
    mov sp, 0xFFFE

    call serial_init

    mov bx, message
    call print
forever:
    jmp forever


print:
    mov al, [bx]
    cmp al, 0
    je print_end
    call putc
    inc bx
    jmp print

print_end:
    ret


putc:
    push dx
    mov dx, COM0
    out dx, al
    pop dx
    ret


serial_init:
    push bx
    push dx

    mov bx, serial_config
    dec bx ; we will index from 1
    mov ax, [bx + IER]
    mov dx, COM0 + IER
    out dx, al
    mov ax, [bx + FCR]
    mov dx, COM0 + FCR
    out dx, al
    mov ax, [bx + LCR]
    mov dx, COM0 + LCR
    out dx, al
    mov ax, [bx + MCR]
    mov dx, COM0 + MCR
    out dx, al

    mov dx, COM0 + LCR
    in al, dx
    push ax
    or ax, DLAB
    mov dx, COM0 + LCR
    out dx, al
    mov bx, serial_baud_rate
    mov ax, [bx + DLL]
    mov dx, COM0 + DLL
    out dx, al
    mov ax, [bx + DLH]
    mov dx, COM0 + DLH
    out dx, al
    mov bx, DLAB
    not bx
    pop ax
    and ax, bx
    mov dx, COM0 + LCR
    out dx, al

    pop dx
    pop bx
    ret


serial_config:
    db 0 ; IER --> no interrupt
    db 0 ; FCR --> no fifo
    db 0x3 ; LCR --> 8n1
    db 0x3 ; MCR --> DTR + RTS


serial_baud_rate:
    ; baude rate: 115200
    db 1 ; DLL
    db 0 ; DLH


message:
    db 'Hello PC! Where is BIOS?', 0xa, 0x0


section .text2 start=0xFFF0

jmp 0xF000:start
