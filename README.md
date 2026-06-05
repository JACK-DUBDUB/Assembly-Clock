# Assembly Clock

A digital clock simulator implemented in x86 Assembly language (8086/8088 compatible) for DOS environments.

## Overview

This repository contains two variants of a real-time digital clock program written in Assembly:

- **12HCLOCK.asm** — Simplified 12-hour clock with single-digit input.
- **24HCLOCK.asm** — Full 24-hour clock supporting two-digit inputs (hours 00-23, minutes/seconds 00-59).

Both programs allow the user to set a starting time and simulate the clock ticking every second in the console. Developed as University Assessment 2.

The code demonstrates low-level concepts: user input handling, validation, time arithmetic with carry-over, modular procedures, and DOS interrupts (`INT 21h`).

## Features

- Interactive input with validation and retry logic.
- Early exit with `q` or `Q`.
- Accurate second-by-second ticking and display (`HH:MM:SS`).
- Modular design with reusable procedures.

## Requirements

- DOS environment or DOSBox.
- MASM/TASM assembler (primary).
- Compiled successfully with MinGW tools.

## Building and Running

### MASM (Recommended)

```bash
masm 24HCLOCK.asm
link 24HCLOCK.obj
24HCLOCK.exe
```

### MinGW

```bash
# Adjust for your 16-bit MinGW setup
as -o 24HCLOCK.o 24HCLOCK.asm
ld -o 24HCLOCK.exe 24HCLOCK.o
```

Run and follow prompts.

## Project Structure

- `12HCLOCK.asm`
- `24HCLOCK.asm`
- `clock_function.asm`
- `INSTRUCTIONS.txt` (if present)
- `LOGIC FLOW.txt` (if present)
- `README.md`


## License

Educational open project. Feel free to use and learn from it. Attribution appreciated.

---

**Note**: For educational low-level programming practice only.
