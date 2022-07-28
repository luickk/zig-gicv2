# Zig gicv3

This repository contains a basic generic interrupt controller for aarch64, specifically the a57 (tested on qemu). Gicv3 docs can be found [here](https://developer.arm.com/documentation/ihi0069/latest).
This project serves debugging purposes for another project of mine and as such does not cover all possible excepions/ interrupts but only the ones I needed.

## Usage

`intHandle.zig` provides the `common_trap_handler`fn which is exported and later linked with the `exception_vec.S` which is linked in the boot entry asm(before stack init) and tells the cpu where to find all interrupt handling functions.

boot.S:
```asm  
// setting up int. excp. vec. table
ldr x0, = exception_vector_table
msr vbar_el1, x0
```

The exception table also needs to be aligned properly so this linker file entry is mandatory:
```
. = ALIGN(0x800);
.text.exceptions : { *(.text.exceptions) }
```