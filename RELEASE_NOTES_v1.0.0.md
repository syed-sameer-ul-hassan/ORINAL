Orinal v1.0.0 — Initial release
=================================

Summary
-------
This is the initial, small and self-contained release of Orinal — a tiny x86 boot sector that demonstrates:

- 32-bit protected mode switching from a BIOS-loaded 512-byte sector
- Simple VGA text output via the text buffer at `0xB8000`
- PIC remapping and IRQ1 (keyboard) handler that prints scancodes
- Minimal build/run via `Makefile` and optional Docker build image

Included artifacts
------------------
- `build/releases/orinal-v1.0.0.zip`
- `build/releases/orinal-v1.0.0.tar.gz`
- `build/releases/orinal-v1.0.0.tar`

Important files in the repo
--------------------------
- `src/boot.asm` — the 512-byte boot sector assembly.
- `Makefile` — build and run targets (creates `build/boot.bin` and `build/disk.img`).
- `Dockerfile` — reproduce the build/run environment in a container.
- `README.md` — usage and design overview.
- `LICENSE` — MIT license.

How to verify locally
---------------------
Build and run with host tools:

```bash
make
make run
```

Build and run inside Docker (no host toolchain required):

```bash
docker build -t orinal .
docker run --rm -it -v "$PWD":/orinal -w /orinal orinal make run
```

Notes
-----
- This release purposely omits full scrolling and serial output to keep the boot sector small.
- For debugging hangs, run QEMU with `-d int,cpu_reset` or kill stray QEMU processes as described in `README.md`.

Next suggested steps (v1.x)
--------------------------
- Add proper VGA scrolling and restore serial output.
- Implement a second-stage loader to switch to 64-bit long mode.
- Add PS/2 scancode translation to a simple input buffer and a tiny shell.
