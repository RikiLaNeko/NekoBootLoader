<div align="center">
  <h1 style="font-size: 4em; font-weight: bold; text-shadow: 2px 2px 4px #000000;">NekoBootLoader</h1>
  <p>
    <i>An exploration into the depths of x86 Assembly bootloaders.</i>
  </p>
  <p>
    <a href="https://www.nasm.us/"><img src="https://img.shields.io/badge/Assembler-NASM-blue.svg" alt="NASM"></a>
    <a href="https://www.qemu.org/"><img src="https://img.shields.io/badge/Emulator-QEMU-orange.svg" alt="QEMU"></a>
    <a href="#"><img src="https://img.shields.io/badge/Arch-x86__64-brightgreen.svg" alt="x86_64"></a>
    <a href="#"><img src="https://img.shields.io/badge/Mode-64--bit%20Long%20Mode-purple.svg" alt="64-bit Long Mode"></a>
  </p>
</div>

<p align="center">
  <a href="#-français">Français</a> | <a href="#-english">English</a>
</p>

---

<details>
<summary><h2>🇫🇷 Français</h2></summary>

### À propos de ce projet

Ce dépôt contient le code source de deux bootloaders différents pour l'architecture x86, écrits en assembleur NASM. Il s'agit d'un projet d'apprentissage pour comprendre le processus de démarrage, du mode réel 16 bits initial au puissant mode long 64 bits.

#### Fonctionnalités

- **Deux Bootloaders :**
  1.  Un bootloader simple de **16 bits** (`boot_x86.asm`) qui affiche un message à l'écran.
  2.  Un bootloader plus avancé de **64 bits en deux étapes** (`boot1.asm` & `boot2.asm`) qui passe par le mode protégé pour atteindre le mode long et affiche un message.
- **Changement de Mode :** Démontre la transition du Mode Réel 16 bits -> Mode Protégé 32 bits -> Mode Long 64 bits.
- **GDT & Pagination :** Inclut la configuration de la Global Descriptor Table (GDT) et des structures de pagination de base requises pour le mode long.
- **Intégration QEMU :** Fourni avec des scripts pour assembler et exécuter facilement les bootloaders dans l'émulateur QEMU.

### Pour commencer

#### Prérequis

- Assembleur [NASM](https://www.nasm.us/)
- Émulateur [QEMU](https://www.qemu.org/)

#### Comment utiliser

##### 1. Le Bootloader Simple 16-bits

Ce bootloader (`boot_x86.asm`) efface simplement l'écran et affiche un message de bienvenue.

Pour l'exécuter, lancez la commande suivante :
```bash
./run_x86.sh
```

##### 2. Le Bootloader 64-bits (Long Mode)

C'est un bootloader en deux étapes.
- `boot1.asm` : La première étape, chargée par le BIOS. Elle charge la deuxième étape depuis le disque.
- `boot2.asm` : La deuxième étape. Elle gère la transition vers le mode protégé puis vers le mode long, met en place la pagination, et enfin affiche un message depuis le code 64 bits.

Pour l'exécuter, lancez la commande suivante :
```bash
./run_x86_64.sh
```

#### Nettoyage

Pour supprimer tous les binaires compilés et l'image disque, exécutez le script de nettoyage :
```bash
./cleanup.sh
```

</details>

---

<details open>
<summary><h2>🇬🇧 English</h2></summary>

### About This Project

This repository contains the source code for two different bootloaders for the x86 architecture, written in NASM assembly. It serves as a learning project to understand the boot process, from the initial 16-bit real mode to the powerful 64-bit long mode.

#### Features

- **Two Bootloaders:**
  1.  A simple **16-bit bootloader** (`boot_x86.asm`) that prints a message to the screen.
  2.  A more advanced **two-stage 64-bit bootloader** (`boot1.asm` & `boot2.asm`) that transitions through protected mode to long mode and displays a message.
- **Mode Switching:** Demonstrates the transition from 16-bit Real Mode -> 32-bit Protected Mode -> 64-bit Long Mode.
- **GDT & Paging:** Includes the setup for Global Descriptor Table (GDT) and basic Paging structures required for long mode.
- **QEMU Integration:** Comes with scripts to easily assemble and run the bootloaders in the QEMU emulator.

### Getting Started

#### Prerequisites

- [NASM](https://www.nasm.us/) Assembler
- [QEMU](https://www.qemu.org/) Emulator

#### How to Use

##### 1. The Simple 16-bit Bootloader

This bootloader (`boot_x86.asm`) simply clears the screen and prints a welcome message.

To run it, execute the following command:

```bash
./run_x86.sh
```

##### 2. The 64-bit Long Mode Bootloader

This is a two-stage bootloader.
- `boot1.asm`: The first stage, loaded by the BIOS. It loads the second stage from the disk.
- `boot2.asm`: The second stage. It handles the transition to protected mode and then to long mode, sets up paging, and finally prints a message from 64-bit code.

To run it, execute the following command:

```bash
./run_x86_64.sh
```

#### Cleanup

To remove all compiled binaries and the disk image, run the cleanup script:

```bash
./cleanup.sh
```

</details>

---

<div align="center">
  <p>Crafted with ❤️ by <span style="font-weight: bold;"><span style="color: #ff0000;">R</span><span style="color: #ff7f00;">i</span><span style="color: #ffff00;">k</span><span style="color: #00ff00;">i</span><span style="color: #0000ff;">L</span><span style="color: #4b0082;">a</span><span style="color: #9400d3;">N</span><span style="color: #ff0000;">e</span><span style="color: #ff7f00;">k</span><span style="color: #ffff00;">o</span></span></p>
</div>
