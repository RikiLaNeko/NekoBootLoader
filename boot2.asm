; boot2.asm - Stage 2 Bootloader (Version corrigée)
bits 16
org 0x1000

start_stage2:
    cli
    
    ; Debug: afficher "2" pour confirmer qu'on arrive ici
    mov ah, 0x0E
    mov al, '2'
    int 0x10
    
    ; Charger GDT
    lgdt [gdt_descriptor]
    
    ; Debug: afficher "G" après chargement GDT
    mov ah, 0x0E
    mov al, 'G'
    int 0x10
    
    ; Passer en mode protégé 32-bit
    mov eax, cr0
    or eax, 1
    mov cr0, eax
    
    ; Far jump pour vider le pipeline
    jmp 0x08:protected_mode_32

bits 32
protected_mode_32:
    ; Configurer segments 32-bit
    mov ax, 0x10
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    mov esp, 0x90000
    
    ; Debug: mettre 'P' à l'écran pour indiquer qu'on est en mode protégé
    mov byte [0xb8000], 'P'
    mov byte [0xb8001], 0x0F
    
    ; Setup paging tables (sans vérification 64-bit pour le moment)
    call setup_paging
    
    ; Debug: mettre 'S' pour indiquer setup fait
    mov byte [0xb8002], 'S'
    mov byte [0xb8003], 0x0F
    
    ; Activer PAE (Physical Address Extension)
    mov eax, cr4
    or eax, (1 << 5)        ; PAE bit
    mov cr4, eax
    
    ; Debug: mettre 'A' pour PAE activé
    mov byte [0xb8004], 'A'
    mov byte [0xb8005], 0x0F
    
    ; Charger PML4 dans CR3
    mov eax, pml4_table
    mov cr3, eax
    
    ; Debug: mettre 'C' pour CR3 chargé
    mov byte [0xb8006], 'C'
    mov byte [0xb8007], 0x0F
    
    ; Activer Long Mode dans EFER MSR
    mov ecx, 0xC0000080     ; IA32_EFER MSR
    rdmsr
    or eax, (1 << 8)        ; LME bit
    wrmsr
    
    ; Debug: mettre 'E' pour EFER configuré
    mov byte [0xb8008], 'E'
    mov byte [0xb8009], 0x0F
    
    ; Activer paging - ceci active aussi le Long Mode
    mov eax, cr0
    or eax, (1 << 31)       ; PG bit
    mov cr0, eax
    
    ; Debug: mettre 'L' pour Long Mode activé
    mov byte [0xb800a], 'L'
    mov byte [0xb800b], 0x0F
    
    ; Far jump vers code 64-bit
    jmp 0x18:long_mode_64

; Fonction 32-bit pour setup paging
setup_paging:
    pushad
    
    ; Clear all paging tables
    mov edi, pml4_table
    mov ecx, (4096 * 4) / 4     ; 4 pages
    xor eax, eax
    rep stosd
    
    ; Setup PML4 entry 0 -> PDPT
    mov dword [pml4_table], pdpt_table
    or dword [pml4_table], 0x3  ; Present + Writable
    mov dword [pml4_table + 4], 0
    
    ; Setup PDPT entry 0 -> PD 
    mov dword [pdpt_table], pd_table
    or dword [pdpt_table], 0x3  ; Present + Writable
    mov dword [pdpt_table + 4], 0
    
    ; Setup PD entry 0 -> PT
    mov dword [pd_table], pt_table
    or dword [pd_table], 0x3    ; Present + Writable
    mov dword [pd_table + 4], 0
    
    ; Identity map first 2MB (512 pages of 4KB each)
    mov edi, pt_table
    mov eax, 0x3                ; Present + Writable
    mov ecx, 512                ; 512 pages
    
.map_pages:
    mov [edi], eax
    mov dword [edi + 4], 0      ; High 32 bits
    add eax, 0x1000             ; Next page (4KB)
    add edi, 8                  ; Next entry (64-bit)
    loop .map_pages
    
    popad
    ret

; Fonction 32-bit pour vérifier le support 64-bit
check_64bit_support:
    pushad
    
    ; Check if CPUID is supported
    pushfd
    pop eax
    mov ecx, eax
    xor eax, (1 << 21)          ; Flip CPUID bit
    push eax
    popfd
    pushfd
    pop eax
    push ecx
    popfd
    cmp eax, ecx
    je .no_cpuid
    
    ; Check for extended CPUID functions
    mov eax, 0x80000000
    cpuid
    cmp eax, 0x80000001
    jb .no_64bit
    
    ; Check Long Mode support
    mov eax, 0x80000001
    cpuid
    test edx, (1 << 29)         ; Long Mode bit
    jz .no_64bit
    
    popad
    ret

.no_cpuid:
.no_64bit:
    ; Print error and halt
    popad
    hlt
    jmp $-1

bits 64
long_mode_64:
    ; Debug: mettre '6' pour indiquer qu'on est en 64-bit
    mov byte [0xb800c], '6'
    mov byte [0xb800d], 0x0F
    
    ; Setup 64-bit segments
    mov ax, 0x20
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    
    ; Print message
    mov rsi, msg
    mov rdi, 0xb8000
    
.print_loop:
    lodsb                       ; Load byte from [RSI] into AL
    test al, al                 ; Check for null terminator
    jz .print_done
    
    mov ah, 0x0F                ; White on black
    mov [rdi], ax               ; Store char + attribute
    add rdi, 2                  ; Move to next screen position
    jmp .print_loop
    
.print_done:
    ; Infinite loop
    cli
.halt:
    hlt
    jmp .halt

; --- Data ---
msg db "Hello from 64-bit Long Mode!", 0

; --- Paging Tables (4KB aligned) ---
align 4096
pml4_table:
    times 4096 db 0

align 4096
pdpt_table:
    times 4096 db 0
    
align 4096
pd_table:
    times 4096 db 0
    
align 4096
pt_table:
    times 4096 db 0

; --- GDT ---
align 8
gdt_start:
    ; Null descriptor
    dq 0x0000000000000000
    
    ; 32-bit code segment (0x08)
    dq 0x00CF9A000000FFFF
    
    ; 32-bit data segment (0x10) 
    dq 0x00CF92000000FFFF
    
    ; 64-bit code segment (0x18)
    dq 0x00AF9A000000FFFF       ; L=1, D=0, G=1, Base=0, Limit=4G
    
    ; 64-bit data segment (0x20)
    dq 0x00CF92000000FFFF       ; G=1, Base=0, Limit=4G

gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start - 1  ; Limit
    dd gdt_start                ; Base
