; boot1.asm - Stage 1 Bootloader (512 bytes max)
bits 16
org 0x7C00

start:
    ; Stocker boot drive (valeur initiale DL) dans BOOT_DRIVE
    mov [BOOT_DRIVE], dl

    ; Désactiver interruptions
    cli
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00

    ; Message "Loading..."
    mov si, msg_loading
    call print_string

    ; Préparer buffer ES:BX = 0x0000:0x1000
    mov ax, 0x0000
    mov es, ax
    mov bx, 0x1000       ; adresse 0x1000

    ; Lire 10 secteurs à partir du secteur 2, cylindre 0, tête 0
    mov ah, 0x02         ; fonction lire secteurs
    mov al, 41           ; nombre de secteurs à lire
    mov ch, 0            ; cylindre 0
    mov cl, 2            ; secteur 2 (secteur 1 = boot1)
    mov dh, 0            ; tête 0
    mov dl, [BOOT_DRIVE]
    int 0x13
    jc disk_error

    ; Sauter au stage 2 en mémoire à 0x1000
    jmp 0x0000:0x1000

disk_error:
    mov si, msg_disk_error
    call print_string
    hlt

print_string:
    mov ah, 0x0E
.next:
    lodsb
    cmp al, 0
    je .done
    int 0x10
    jmp .next
.done:
    ret

msg_loading: db "Loading stage 2...", 0
msg_disk_error: db "Disk read error!", 0
BOOT_DRIVE: db 0

times 510-($-$$) db 0
dw 0xAA55

