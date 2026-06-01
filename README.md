# Orinal – tiny bootable kernel (just for fun/testing how kernels work)

<p align="center">
  <img src="./assets/logo.svg" alt="Orinal logo" width="320" />
</p>

Orinal is a minimalist x86_64 boot sector for learning and experimentation. It sets up a flat 32-bit protected mode, prints to VGA text memory, and logs keyboard scancodes over IRQ1. It is intentionally small so you can see early boot and interrupt handling.

## Quick start (host tools installed)
1. Install `nasm` and `qemu-system-x86_64` on your host.
2. Build: `make`
3. Run (headless, serial to your terminal): `make run`

## Using Docker (no host toolchain needed)
1. Build the image:
   ```bash
docker build -t orinal .
   ```
2. Run build & boot via QEMU inside the container (mounts your workspace):
   ```bash
docker run --rm -it -v "$PWD":/orinal -w /orinal orinal make run
   ```
   Notes:
   - Local folder is `karnal`, but inside the container we work in `/orinal` to match the image name.
   - Current QEMU run uses a 10MB raw disk image and IDE boot; if you see hangs, check the troubleshooting section.

## Files
- `src/boot.asm` – 512-byte boot sector: switches to 32-bit protected mode, sets up a flat GDT, clears VGA text screen, installs IDT for IRQ1 (keyboard), logs scancodes to VGA, wraps rows/cols.
- `Makefile` – builds `build/boot.bin`, pads `build/disk.img` (10MB), and runs QEMU.
- `Dockerfile` – minimal environment (nasm + qemu) to build/run.
- `assets/logo.svg` – theme-aware logo (light/dark via `prefers-color-scheme`).

## How it works (current)
- BIOS loads the sector to `0x7C00`, we set a flat GDT, enable protected mode, set up stack, and point VGA to 0xB8000.
- Keyboard: IRQ1 handler reads the scancode byte and prints it in hex to VGA; Enter triggers a newline. (Serial output removed to save space.)
- Row/col wrap: when the screen fills, we wrap to the top (no scrolling to save space in the boot sector).
- Boot signature: 0x55AA at the end of the sector.

### Execution flow (high-level)
1) BIOS loads boot sector @0x7C00 (16-bit)
2) Enable A20, load GDT, switch to 32-bit
3) Clear VGA text buffer
4) Install IDT for IRQ1 (keyboard), remap PIC, STI
5) HLT loop; IRQ1 prints scancode hex on key press

### Memory view (text buffer)
- VGA text base 0xB8000, offset = (row*80+col)*2
- Each cell: [char][attr]

## Next ideas
- Add proper scrolling and serial output back in.
- Switch to 64-bit long mode with a second-stage loader (C or Rust).
- Add PS/2 translation to ASCII and a simple shell-like input buffer.
- Add a tiny heap/allocator and a simple task loop.

## Troubleshooting
- If QEMU says it can’t lock the image: kill stray qemu processes (`sudo pkill -f qemu-system-x86_64`) and rerun `make run` inside Docker.
- If BIOS hangs after “Booting from Floppy/Hard Disk”: try hard-disk boot with `make run` (Makefile now uses IDE disk). For debugging, run QEMU with `-d int,cpu_reset` to see reset/triple-fault info.
# ORINAL
