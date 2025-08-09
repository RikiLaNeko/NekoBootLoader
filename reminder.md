# Rappel : Charger un noyau C avec le Bootloader 64-bit

Pour utiliser ce bootloader afin de lancer un système d'exploitation écrit en C, voici les étapes clés à suivre :

### 1. Préparer le Noyau C

- **Compiler en binaire plat :** Le code source de votre noyau C doit être compilé en un fichier binaire simple (ex: `kernel.bin`), et non en un exécutable standard (comme ELF). Utilisez les options de votre linker pour cela (par exemple, `ld -T link.ld -o kernel.bin ...`).
- **Point d'entrée :** Votre noyau C doit avoir un point d'entrée bien défini (une fonction comme `_start` ou `kmain`) que le bootloader pourra appeler. Cette fonction ne recevra pas d'arguments comme un `main` classique.

### 2. Mettre à jour l'image disque

Modifiez le script `run_x86_64.sh` pour assembler l'image disque (`os.img`) dans le bon ordre :

1.  **`boot1.bin`** (Stage 1) au tout début de l'image (secteur 0).
2.  **`boot2.bin`** (Stage 2) juste après (à partir du secteur 1).
3.  **`kernel.bin`** (votre noyau) juste après `boot2.bin`.

Exemple de commandes `dd` :
```bash
# Écrire Stage 1
dd if=boot1.bin of=os.img bs=512 count=1 conv=notrunc

# Écrire Stage 2
dd if=boot2.bin of=os.img bs=512 seek=1 conv=notrunc

# Écrire le noyau (par exemple, à partir du 42ème secteur)
dd if=kernel.bin of=os.img bs=512 seek=42 conv=notrunc
```

### 3. Adapter le Bootloader

- **`boot1.asm` (Chargement) :**
  - Ajustez le nombre de secteurs à lire. La ligne `mov al, 41` doit être modifiée pour charger `boot2.bin` ET `kernel.bin`. Calculez la taille totale en secteurs et mettez à jour cette valeur.

- **`boot2.asm` (Passage de contrôle) :**
  - À la toute fin, dans la section `long_mode_64`, supprimez le code qui affiche le message "Hello from 64-bit Long Mode!".
  - Remplacez-le par un saut inconditionnel (`jmp`) vers l'adresse mémoire où `kernel.bin` a été chargé. Si `boot2.bin` commence à `0x1000` et que votre noyau est chargé juste après, vous devrez calculer cette adresse de départ et y sauter.
