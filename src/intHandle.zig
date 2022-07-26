const gic = @import("gicv3.zig");
const Gicc = gic.Gicc;
const Gicd = gic.Gicd;

const psw = @import("psw.zig");
const espP = @import("espReg.zig");
const utils = @import("utils.zig");

pub const daifIrqBit: u8 = 1 << 1; // IRQ mask bit

pub fn common_trap_handler(exc: *gic.ExceptionFrame) callconv(.C) void {
    handleException(exc);
    // only required for asyn interrupts..
    // intHandle(exc);
    return;
}

fn intHandle(exc: *gic.ExceptionFrame) void {
    var psw_temp: u64 = undefined;
    var irq: gic.irqNo = undefined;
    var rc: u32 = undefined;

    psw.pswDisableAndSaveInterrupt(&psw_temp);
    rc = Gicc.gicV3FindPendingIrq(exc, &irq);
    if (rc != 0) {
        psw.psw_restore_interrupt(&psw_temp);
        return;
    }
    Gicd.gicdDisableInt(irq); // Mask this irq
    Gicc.gicV3Eoi(irq); // Send EOI for this irq line
    Gicd.gicdEnableInt(irq); // unmask this irq line
}

fn handleException(exc: *gic.ExceptionFrame) void {
    utils.qemuDPrint("An exception occur:\n");
    utils.qemuDPrint("elr: ");
    utils.qemuUintPrint(exc.elr_el1, utils.PrintStyle.string);
    utils.qemuDPrint(", esr: ");
    utils.qemuUintPrint(exc.esr_el1, utils.PrintStyle.hex);
    utils.qemuDPrint("\n");

    utils.qemuDPrint("(");
    for (exc.regs) |reg, i| {
        utils.qemuDPrint("x");
        utils.qemuUintPrint(i, utils.PrintStyle.string);
        utils.qemuDPrint(":");
        utils.qemuUintPrint(reg, utils.PrintStyle.string);
        utils.qemuDPrint(", ");
    }
    utils.qemuDPrint(") \n");

    var iss = @truncate(u25, exc.esr_el1);
    var il = @truncate(u1, exc.esr_el1 >> 25);
    var ec = @truncate(u6, exc.esr_el1 >> 27);
    var iss2 = @truncate(u5, exc.esr_el1 >> 32);
    _ = iss;
    _ = iss2;

    var ec_en = utils.intToEnum(espP.ExceptionClass, ec) catch {
        utils.qemuDPrint("esp exception class not found \n");
        return;
    };

    if (il == 1) {
        utils.qemuDPrint("32 bit instruction trapped \n");
    } else {
        utils.qemuDPrint("16 bit instruction trapped \n");
    }

    utils.qemuDPrint("Exception Class(from esp reg): ");
    utils.qemuDPrint(@tagName(ec_en));
    utils.qemuDPrint("\n");
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
