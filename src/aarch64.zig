const daif_irq_bit = 1 << 1; // IRQ mask bit

const timer_irq = 27;

const qemu_virt_gic_base = 0x08000000;
const qemu_virt_gic_int_max = 64;

const gic_base = qemu_virt_gic_base;
const gic_int_max = qemu_virt_gic_int_max;

// DAIF, Interrupt Mask Bits
// 	Allows access to the interrupt mask bits.
// 	D, bit [9]: Debug exceptions.
// 	A, bit [8]: SError (System Error) mask bit.
// 	I, bit [7]: IRQ mask bit.
// 	F, bit [6]: FIQ mask bit.
// 	value:
// 		0 Exception not masked.
// 		1 Exception masked.
pub fn raw_read_daif() u32 {
    var daif: u32 = asm volatile ("mrs %[daif], DAIF"
        : [daif] "=r" (-> u32),
    );
    return daif;
}

pub fn enable_irq() void {
    asm volatile ("msr DAIFClr, %[daif_irq_bit]"(daif_irq_bit));
}

pub fn disable_irq() void {
    asm volatile ("msr DAIFSet, %[daif_irq_bit]"(daif_irq_bit));
}

pub fn raw_write_daif(daif: u32) void {
    asm volatile ("msr DAIF, %[daif]"(daif));
}
