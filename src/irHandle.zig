const psw = @import("procStatWord.zig");
const gic = @import("gicv3.zig");
const utils = @import("utils.zig");

pub const daifIrqBit: u8 = 1 << 1; // IRQ mask bit

// aarch64 exception types
// current el with sp0
pub const ExcTypeSp0 = enum(u8) {
    syncSp0 = 0x1, // synchronous
    irqSp0 = 0x2, // irq/virq
    fiqSp0 = 0x3, // fiq/vfiq
    serrSp0 = 0x4, // serror/vserror
};

// current el with spx
pub const ExcTypeSpx = enum(u8) {
    syncSpx = 0x11,
    irqSpx = 0x12,
    fiqSpx = 0x13,
    serrSpx = 0x14,
};

// lower el using aarch64
pub const ExcTypeLower = enum(u8) {
    sync = 0x21,
    irq = 0x22,
    fiq = 0x23,
    serr = 0x24,
};

fn handleException(exc: *gic.ExceptionFrame) void {
    utils.qemuDPrint("An exception occur:\n");
    utils.qemuDPrint("exc_type: ");
    utils.qemuUintPrint(exc.exc_type, utils.PrintStyle.string);
    utils.qemuDPrint("\nESR: ");
    utils.qemuUintPrint(exc.exc_esr, utils.PrintStyle.string);
    utils.qemuDPrint("  SP: ");
    utils.qemuUintPrint(exc.exc_sp, utils.PrintStyle.string);
    utils.qemuDPrint(" ELR: ");
    utils.qemuUintPrint(exc.exc_elr, utils.PrintStyle.string);
    utils.qemuDPrint(" SPSR: ");
    utils.qemuUintPrint(exc.exc_spsr, utils.PrintStyle.string);
    utils.qemuDPrint("\n x0: ");
    utils.qemuUintPrint(exc.x0, utils.PrintStyle.string);
    utils.qemuDPrint("  x1: ");
    utils.qemuUintPrint(exc.x1, utils.PrintStyle.string);
    utils.qemuDPrint("  x2: ");
    utils.qemuUintPrint(exc.x2, utils.PrintStyle.string);
    utils.qemuDPrint("  x3: ");
    utils.qemuUintPrint(exc.x3, utils.PrintStyle.string);
    utils.qemuDPrint("\n x4: ");
    utils.qemuUintPrint(exc.x4, utils.PrintStyle.string);
    utils.qemuDPrint("  x5: ");
    utils.qemuUintPrint(exc.x5, utils.PrintStyle.string);
    utils.qemuDPrint("  x6: ");
    utils.qemuUintPrint(exc.x6, utils.PrintStyle.string);
    utils.qemuDPrint("  x7: ");
    utils.qemuUintPrint(exc.x7, utils.PrintStyle.string);
    utils.qemuDPrint("\n x8: ");
    utils.qemuUintPrint(exc.x8, utils.PrintStyle.string);
    utils.qemuDPrint("  x9: ");
    utils.qemuUintPrint(exc.x9, utils.PrintStyle.string);
    utils.qemuDPrint(" x10: ");
    utils.qemuUintPrint(exc.x10, utils.PrintStyle.string);
    utils.qemuDPrint(" x11: ");
    utils.qemuUintPrint(exc.x11, utils.PrintStyle.string);
    utils.qemuDPrint("\nx12: ");
    utils.qemuUintPrint(exc.x12, utils.PrintStyle.string);
    utils.qemuDPrint(" x13: ");
    utils.qemuUintPrint(exc.x13, utils.PrintStyle.string);
    utils.qemuDPrint(" x14: ");
    utils.qemuUintPrint(exc.x14, utils.PrintStyle.string);
    utils.qemuDPrint(" x15: ");
    utils.qemuUintPrint(exc.x15, utils.PrintStyle.string);
    utils.qemuDPrint("\nx16: ");
    utils.qemuUintPrint(exc.x16, utils.PrintStyle.string);
    utils.qemuDPrint(" x17: ");
    utils.qemuUintPrint(exc.x17, utils.PrintStyle.string);
    utils.qemuDPrint(" x18: ");
    utils.qemuUintPrint(exc.x18, utils.PrintStyle.string);
    utils.qemuDPrint(" x19: ");
    utils.qemuUintPrint(exc.x19, utils.PrintStyle.string);
    utils.qemuDPrint("\nx20: ");
    utils.qemuUintPrint(exc.x20, utils.PrintStyle.string);
    utils.qemuDPrint(" x21: ");
    utils.qemuUintPrint(exc.x21, utils.PrintStyle.string);
    utils.qemuDPrint(" x22: ");
    utils.qemuUintPrint(exc.x22, utils.PrintStyle.string);
    utils.qemuDPrint(" x23: ");
    utils.qemuUintPrint(exc.x23, utils.PrintStyle.string);
    utils.qemuDPrint("\nx24: ");
    utils.qemuUintPrint(exc.x24, utils.PrintStyle.string);
    utils.qemuDPrint(" x25: ");
    utils.qemuUintPrint(exc.x25, utils.PrintStyle.string);
    utils.qemuDPrint(" x26: ");
    utils.qemuUintPrint(exc.x26, utils.PrintStyle.string);
    utils.qemuDPrint(" x27: ");
    utils.qemuUintPrint(exc.x27, utils.PrintStyle.string);
    utils.qemuDPrint("\nx28: ");
    utils.qemuUintPrint(exc.x28, utils.PrintStyle.string);
    utils.qemuDPrint(" x29: ");
    utils.qemuUintPrint(exc.x29, utils.PrintStyle.string);
    utils.qemuDPrint(" x30: ");
    utils.qemuUintPrint(exc.x30, utils.PrintStyle.string);
    utils.qemuDPrint("\n");
}

pub fn common_trap_handler(exc: *gic.ExceptionFrame) callconv(.C) void {

    // only handling synchronous ints
    handleException(exc);

    // irHandle(exc);

    // differentiating by sync/ async interrupt
    // if ((exc.exc_type & 0xff) == irqRegs.aarch64_exc_sync_spx) {
    //     utils.qemuDPrint("sync_spx int\n");
    //     handleException(exc);
    // }

    // if ((exc.exc_type & 0xff) == irqRegs.aarch64_exc_irq_spx) {
    //     utils.qemuDPrint("irq_spx int!!\n");
    //     irHandle(exc);
    // }
    return;
}

fn irHandle(exc: *gic.ExceptionFrame) void {
    var psw_temp: psw.psw_t = undefined;
    var irq: gic.irq_no = undefined;
    var rc: u32 = undefined;

    psw.psw_disable_and_save_interrupt(&psw_temp);
    rc = gic.gic_v3_find_pending_irq(exc, &irq);
    if (rc != 0) {
        // utils.qemuDPrint("IRQ not found!\n");
        psw.psw_restore_interrupt(&psw_temp);
        return;
    } else {
        utils.qemuDPrint("IRQ found: ");
        utils.qemuUintPrint(irq, utils.PrintStyle.string);
        utils.qemuDPrint("\n");
    }
    gic.gicd_disable_int(irq); // Mask this irq
    gic.gic_v3_eoi(irq); // Send EOI for this irq line
    // timer_handler();
    gic.gicd_enable_int(irq); // unmask this irq line
}

// DAIF, Interrupt Mask Bits
//  Allows access to the interrupt mask bits.
//  D, bit [9]: Debug exceptions.
//  A, bit [8]: SError (System Error) mask bit.
//  I, bit [7]: IRQ mask bit.
//  F, bit [6]: FIQ mask bit.
//  value:
//      0 Exception not masked.
//      1 Exception masked.
pub fn raw_read_daif() u32 {
    var daif: u32 = asm volatile ("mrs %[daif], DAIF"
        : [daif] "=r" (-> u32),
    );
    return daif;
}

pub fn enable_irq() void {
    asm volatile ("msr DAIFClr, %[daif_irq_bit]"
        :
        : [daif_irq_bit] "i" (daifIrqBit),
    );
}

pub fn disable_irq() void {
    asm volatile ("msr DAIFSet, %[daif_irq_bit]"
        :
        : [daif_irq_bit] "i" (daifIrqBit),
    );
}

pub fn raw_write_daif(daif: u32) void {
    _ = daif;
    asm volatile ("msr DAIF, %[daif]"
        :
        : [daif] "r" (daif),
    );
}
