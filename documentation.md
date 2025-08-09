# Technical Documentation

This document provides a technical overview of the files in the `NekoBootLoader` project.

## Bootloaders

### 1. Simple 16-bit Bootloader (`boot_x86.asm`)

This is a single-stage bootloader that fits within the 512-byte boot sector.

- **Execution Flow:**
  1.  Sets up the stack.
  2.  Calls a `clearscreen` routine using BIOS interrupt `0x10`.
  3.  Moves the cursor to the top-left corner (0,0).
  4.  Calls a `print` routine to display the message `"Hello le panda-roux, oui, ceci est un bootloader ecrit en asm oui"`.
  5.  Enters an infinite loop (`hlt`).

- **Key Functions:**
  - `clearscreen`: Uses BIOS interrupt `0x10` (function `0x07`) to scroll the window, effectively clearing it.
  - `movecursor`: Uses BIOS interrupt `0x10` (function `0x02`) to set the cursor position.
  - `print`: Loops through a null-terminated string, printing each character using BIOS interrupt `0x10` (function `0x0E`, TTY output).

### 2. 64-bit Long Mode Bootloader

This is a more complex, two-stage bootloader designed to enter 64-bit long mode.

#### Stage 1: `boot1.asm`

This is the initial 512-byte boot sector code.

- **Purpose:** Load the second stage of the bootloader from the disk into memory.
- **Execution Flow:**
  1.  Disables interrupts (`cli`).
  2.  Sets up segment registers and the stack.
  3.  Prints a "Loading stage 2..." message.
  4.  Uses BIOS interrupt `0x13` (function `0x02`) to read 41 sectors from the disk (starting from the second sector) into memory at address `0x1000`.
  5.  Jumps to the loaded code at `0x1000`, starting the execution of Stage 2.
  6.  Includes basic error handling for disk read failures.

#### Stage 2: `boot2.asm`

This code is loaded by Stage 1 and performs the transition to 64-bit mode.

- **Execution Flow:**
  1.  **16-bit Real Mode:**
      - Starts execution at `0x1000`.
      - Loads the Global Descriptor Table (GDT) using `lgdt`.
  2.  **Transition to 32-bit Protected Mode:**
      - Sets the `PE` bit in the `cr0` register.
      - Performs a far jump to flush the CPU pipeline and load the new `cs` selector from the GDT.
  3.  **32-bit Protected Mode:**
      - Sets up the 32-bit data segment registers (`ds`, `es`, etc.).
      - Sets up the stack pointer (`esp`).
      - Calls `setup_paging` to create the necessary page tables for long mode (PML4, PDPT, PD, PT). It identity-maps the first 2MB of memory.
      - Enables Physical Address Extension (PAE) by setting the `PAE` bit in `cr4`.
      - Loads the PML4 address into the `cr3` register.
      - Enables long mode by setting the `LME` bit in the `IA32_EFER` MSR.
  4.  **Transition to 64-bit Long Mode:**
      - Enables paging by setting the `PG` bit in `cr0`. This, combined with the previous steps, activates long mode.
      - Performs a far jump to a 64-bit code segment.
  5.  **64-bit Long Mode:**
      - Sets up the 64-bit data segment registers.
      - Clears the screen by directly writing to the video memory buffer at `0xb8000`.
      - Prints the final message: `"Hello from 64-bit Long Mode!"`.
      - Enters an infinite loop.

- **Key Components:**
  - **GDT (`gdt_start`):** Defines segments for 32-bit and 64-bit code and data.
  - **Paging Tables (`pml4_table`, etc.):** 4KB-aligned tables for the 4-level paging required by long mode.

## Scripts

### `run_x86.sh`

- **Purpose:** Assembles and runs the simple 16-bit bootloader.
- **Commands:**
  - `nasm -f bin boot_x86.asm -o boot_x86.com`: Assembles the code into a flat binary.
  - `qemu-system-x86_64 -fda boot_x86.com`: Runs the binary as a floppy disk image in QEMU.

### `run_x86_64.sh`

- **Purpose:** Assembles, combines, and runs the 64-bit bootloader.
- **Commands:**
  - `nasm -f bin boot1.asm -o boot1.bin`: Assembles Stage 1.
  - `nasm -f bin boot2.asm -o boot2.bin`: Assembles Stage 2.
  - `dd if=/dev/zero ...`: Creates an empty 1.44MB floppy disk image (`os.img`).
  - `dd if=boot1.bin ...`: Writes the Stage 1 bootloader to the first sector of the image.
  - `dd if=boot2.bin ...`: Writes the Stage 2 code starting from the second sector of the image.
  - `qemu-system-x86_64 -drive ...`: Boots the created disk image in a 64-bit QEMU machine.

### `cleanup.sh`

- **Purpose:** Removes all generated files.
- **Command:**
  - `rm boot1.bin boot2.bin boot_x86.com os.img`: Deletes the compiled binaries and the disk image.
