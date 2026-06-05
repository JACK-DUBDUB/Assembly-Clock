# Assembly Clock

A digital clock simulator implemented in x86 Assembly language (8086/8088 compatible) for DOS environments.

## Overview

This repository contains two variants of a real-time digital clock program written in Assembly:

- **12HCLOCK.asm** — A simplified 12-hour clock.
- **24HCLOCK.asm** — A complete 24-hour clock supporting full two-digit input for hours (00-23), minutes, and seconds (00-59).

Both programs prompt the user to set a starting time and then simulate the clock ticking every second in the console.

The code demonstrates core low-level programming concepts such as:
- User input handling and validation
- Memory addressing and string operations
- Procedure-based modular design
- Interrupt-driven I/O (`INT 21h`)
- Time arithmetic with carry logic

## Features

- Interactive console input with range validation and retry on errors.
- Early exit option using `q` or `Q`.
- Accurate second-by-second time simulation.
- Clean formatted output (`HH:MM:SS`).
- Educational focus on Assembly language fundamentals.

## Requirements

- DOS-compatible environment (DOSBox recommended).
- Assembler/Linker:
  - Primarily TASM or MASM.
  - Successfully compiled using **MinGW** tools (as per project development).

## Building and Running

### With MinGW (recommended for this setup)

```bash
# Example compilation workflow using MinGW (adjust as per your exact setup)
as -o 24HCLOCK.o 24HCLOCK.asm
ld -o 24HCLOCK.exe 24HCLOCK.o
# Or use appropriate MinGW 16-bit tools if configured
```

For classic TASM/MASM:

```bash
tasm 24HCLOCK.asm
tlink 24HCLOCK.obj
```

Run the executable:

```bash
24HCLOCK.exe
```

Enter the starting time when prompted or press `q` to quit.

The same steps apply to `12HCLOCK.asm`.

## Project Structure

```
Assembly-Clock/
├── 12HCLOCK.asm
├── 24HCLOCK.asm
├── clock_function.asm
├── README.md
└── .gitattributes
```

## Project Details

**Author:** Jack Du Boulay (Student ID: 32712899)  
**Assessment:** University Assembly Programming - Assessment 2  
**Due Date:** 02/11/2025

## License

This is an open educational project. You are welcome to use, study, and modify the code. Attribution is appreciated when reusing.

---

**Note**: Intended for learning low-level programming. Not for production environments.