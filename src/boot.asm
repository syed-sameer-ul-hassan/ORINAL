[org 0x7c00]
[bits 16]

start:
    cli
    xor ax, ax
    mov ds, ax
    mov ss, ax
    mov sp, 0x7c00
    mov al, 0x92
    out 0x92, al
    lgdt [gdt_desc]
    mov eax, cr0
    or eax, 1
    mov cr0, eax
    jmp 0x08:pm_entry

[bits 32]
pm_entry:
    mov ax, 0x10
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    mov esp, 0x90000
    call clear_screen
    call idt_init
    call pic_remap
    sti
    mov esi, msg
    call print_string
main_loop:
    hlt
    jmp main_loop

clear_screen:
    push eax
    push ecx
    push edi
    mov ax, 0x1F20
    mov edi, 0xb8000
    mov ecx, 80*25
    rep stosw
    mov word [row], 0
    mov word [col], 0
    pop edi
    pop ecx
    pop eax
    ret

print_char:
    push eax
    push ebx
    push ecx
    push edi
    mov bl, al
    cmp bl, 0x0a
    je pc_nl
    cmp bl, 0x0d
    je pc_nl
    mov ax, [row]
    mov cx, 80
    mul cx
    add ax, [col]
    shl eax, 1
    mov edi, 0xb8000
    add edi, eax
    mov byte [edi], bl
    mov byte [edi+1], 0x1F
    inc word [col]
    mov ax, [col]
    cmp ax, 80
    jb pc_done
    mov word [col], 0
    inc word [row]
    cmp word [row], 25
    jb pc_done
    mov word [row], 0
    jmp pc_done
pc_nl:
    mov word [col], 0
    inc word [row]
    cmp word [row], 25
    jb pc_done
    mov word [row], 0
pc_done:
    pop edi
    pop ecx
    pop ebx
    pop eax
    ret

print_string:
    lodsb
    test al, al
    jz ps_done
    call print_char
    jmp print_string
ps_done:
    ret

idt_init:
    lea eax, [idt]
    mov dword [idt_desc+2], eax
    lidt [idt_desc]
    ret

pic_remap:
    mov al, 0x11
    out 0x20, al
    out 0xA0, al
    mov al, 0x20
    out 0x21, al
    mov al, 0x28
    out 0xA1, al
    mov al, 0x04
    out 0x21, al
    mov al, 0x02
    out 0xA1, al
    mov al, 0x01
    out 0x21, al
    out 0xA1, al
    mov al, 0xFD        ; only IRQ1
    out 0x21, al
    mov al, 0xFF
    out 0xA1, al
    ret

irq1:
    pushad
    in al, 0x60
    mov bl, al
    test bl, 0x80
    jnz kb_ack
    cmp bl, 0x1c
    je kb_nl
    mov al, bl
    call print_hex
    mov al, 0x20
    call print_char
    jmp kb_ack
kb_nl:
    mov al, 0x0a
    call print_char
kb_ack:
    mov al, 0x20
    out 0x20, al
    popad
    iretd

print_hex:
    push eax
    push ebx
    push esi
    mov bl, al
    shr bl, 4
    mov bh, al
    and bh, 0x0F
    mov esi, hex_table
    movzx eax, bl
    mov al, [esi + eax]
    call print_char
    movzx eax, bh
    mov al, [esi + eax]
    call print_char
    pop esi
    pop ebx
    pop eax
    ret

[bits 16]
gdt:
    dq 0
    dq 0x00CF9A000000FFFF
    dq 0x00CF92000000FFFF
gdt_desc:
    dw gdt_desc - gdt - 1
    dd gdt

[bits 32]
row dw 0
col dw 0
msg db "Orinal IRQ1", 0
hex_table db "0123456789ABCDEF"
idt:
    dw irq1
    dw 0x08
    db 0
    db 0x8E
    dw 0
idt_desc:
    dw (8*1)-1
    dd idt

 times 510-($-$$) db 0
 dw 0xAA55
