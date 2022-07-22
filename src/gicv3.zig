const regs = @import("gicv3Registers.zig");
const aarch64 = @import("aarch64.zig");
const utils = @import("utils.zig");

// todo => consider removing extra type for irq_no. no need for obscuring...
pub const irq_no: type = u32;

pub const ExceptionFrame = extern struct {
    exc_type: u64,
    exc_esr: u64,
    exc_sp: u64,
    exc_elr: u64,
    exc_spsr: u64,
    x0: u64,
    x1: u64,
    x2: u64,
    x3: u64,
    x4: u64,
    x5: u64,
    x6: u64,
    x7: u64,
    x8: u64,
    x9: u64,
    x10: u64,
    x11: u64,
    x12: u64,
    x13: u64,
    x14: u64,
    x15: u64,
    x16: u64,
    x17: u64,
    x18: u64,
    x19: u64,
    x20: u64,
    x21: u64,
    x22: u64,
    x23: u64,
    x24: u64,
    x25: u64,
    x26: u64,
    x27: u64,
    x28: u64,
    x29: u64,
    x30: u64,
};

// initialize gic controller
fn init_gicc() void {
    // disable cpu interface
    regs.reg_gic_gicc_ctlr.* = regs.gicc_ctlr_disable;

    // set the priority level as the lowest priority
    // note: higher priority corresponds to a lower priority field value in the gic_pmr.
    // in addition to this, writing 255 to the gicc_pmr always sets it to the largest supported priority field value.
    regs.reg_gic_gicc_pmr.* = regs.gicc_pmr_prio_min;

    // handle all of interrupts in a single group
    regs.reg_gic_gicc_bpr.* = regs.gicc_bpr_no_group;

    // clear all of the active interrupts
    var pending_irq: u32 = 0;
    while (pending_irq != regs.gicc_iar_spurious_intr) : (pending_irq = regs.reg_gic_gicc_iar.* & regs.gicc_iar_intr_idmask) {
        // pending_irq = ( *reg_gic_gicc_iar & gicc_iar_intr_idmask ) )
        regs.reg_gic_gicc_eoir.* = regs.reg_gic_gicc_iar.*;
    }

    // enable cpu interface
    regs.reg_gic_gicc_ctlr.* = regs.gicc_ctlr_enable;
    utils.qemuDPrint("inited gicc\n");
}

// init the gic distributor
fn init_gicd() void {
    var i: u32 = 0;
    var regs_nr: u32 = 0;

    // utils.qemuDPrint("init_gicd()\n");
    // diable distributor
    regs.reg_gic_gicd_ctlr.* = regs.gic_gicd_ctlr_disable;

    // disable all irqs
    regs_nr = (aarch64.gic_int_max + regs.gic_gicd_int_per_reg - 1) / regs.gic_gicd_int_per_reg;
    while (regs_nr > i) : (i += 1) {
        regs.reg_gic_gicd_icenabler(i).* = ~@as(u32, 0);
    }
    i = 0;

    // clear all pending irqs
    regs_nr = (aarch64.gic_int_max + regs.gic_gicd_int_per_reg - 1) / regs.gic_gicd_int_per_reg;
    while (regs_nr > i) : (i += 1) {
        regs.reg_gic_gicd_icpendr(i).* = ~@as(u32, 0);
    }
    i = 0;

    // set all of interrupt priorities as the lowest priority
    regs_nr = (aarch64.gic_int_max + regs.gic_gicd_ipriority_per_reg - 1) / regs.gic_gicd_ipriority_per_reg;
    while (regs_nr > i) : (i += 1) {
        regs.reg_gic_gicd_ipriorityr(i).* = ~@as(u32, 0);
    }
    i = 0;

    // set target of all of shared peripherals to processor 0
    i = aarch64.gic_intno_spi0 / regs.gic_gicd_itargetsr_per_reg;
    while ((aarch64.gic_int_max + (regs.gic_gicd_itargetsr_per_reg - 1)) / regs.gic_gicd_itargetsr_per_reg > i) : (i += 1) {
        regs.reg_gic_gicd_itargetsr(i).* = @as(u32, regs.gic_gicd_itargetsr_core0_target_bmap);
    }

    // set trigger type for all peripheral interrupts level triggered
    i = aarch64.gic_intno_ppi0 / regs.gic_gicd_icfgr_per_reg;
    while ((aarch64.gic_int_max + (regs.gic_gicd_icfgr_per_reg - 1)) / regs.gic_gicd_icfgr_per_reg > i) : (i += 1) {
        regs.reg_gic_gicd_icfgr(i).* = regs.gic_gicd_icfgr_level;
    }

    // enable distributor
    regs.reg_gic_gicd_ctlr.* = regs.gic_gicd_ctlr_enable;
    utils.qemuDPrint("inited gicd\n");
}

// disable irq
// @param[in] irq irq number
pub fn gicd_disable_int(irq: irq_no) void {
    regs.reg_gic_gicd_icenabler(irq / regs.gic_gicd_icenabler_per_reg).* = @as(u8, 1) << @truncate(u3, irq % regs.gic_gicd_icenabler_per_reg);
}

// enable irq
// @param[in] irq irq number
pub fn gicd_enable_int(irq: irq_no) void {
    regs.reg_gic_gicd_isenabler(irq / regs.gic_gicd_isenabler_per_reg).* = @as(u8, 1) << @truncate(u3, irq % regs.gic_gicd_isenabler_per_reg);
}

// clear a pending interrupt
// @param[in] irq irq number
fn gicd_clear_pending(irq: irq_no) void {
    regs.reg_gic_gicd_icpendr(irq / regs.gic_gicd_icpendr_per_reg).* = @as(u8, 1) << @truncate(u3, irq % regs.gic_gicd_icpendr_per_reg);
}

// probe pending interrupt
// @param[in] irq irq number
fn gicd_probe_pending(irq: irq_no) bool {
    var is_pending = (regs.reg_gic_gicd_ispendr((irq / regs.gic_gicd_ispendr_per_reg)).* & (@as(u8, 1) << @truncate(u3, irq % regs.gic_gicd_ispendr_per_reg)));
    return is_pending != 0;
}

// set an interrupt target processor
// @param[in] irq irq number
// @param[in] p   target processor mask
// 0x1 processor 0
// 0x2 processor 1
// 0x4 processor 2
// 0x8 processor 3
fn gicd_set_target(irq: irq_no, p: u32) void {
    var shift: u5 = @truncate(u5, (irq % regs.gic_gicd_itargetsr_per_reg) * regs.gic_gicd_itargetsr_size_per_reg);

    var reg: u32 = regs.reg_gic_gicd_itargetsr(irq / regs.gic_gicd_itargetsr_per_reg).*;
    reg &= ~(@as(u32, 0xff) << shift);
    reg |= p << shift;
    regs.reg_gic_gicd_itargetsr(irq / regs.gic_gicd_itargetsr_per_reg).* = reg;
}

// set an interrupt priority
// @param[in] irq  irq number
// @param[in] prio interrupt priority in arm specific expression
fn gicd_set_priority(irq: irq_no, prio: u32) void {
    var shift: u5 = @truncate(u5, (irq % regs.gic_gicd_ipriority_per_reg) * regs.gic_gicd_ipriority_size_per_reg);
    var reg: u32 = regs.reg_gic_gicd_ipriorityr(irq / regs.gic_gicd_ipriority_per_reg).*;
    reg &= ~(@as(u32, 0xff) << shift);
    reg |= (prio << shift);
    regs.reg_gic_gicd_ipriorityr(irq / regs.gic_gicd_ipriority_per_reg).* = reg;
}

// configure irq
// @param[in] irq     irq number
// @param[in] config  configuration value for gicd_icfgr
fn gicd_config(irq: irq_no, config: u32) void {
    var shift: u5 = @truncate(u5, (irq % regs.gic_gicd_icfgr_per_reg) * regs.gic_gicd_icfgr_size_per_reg); // gicd_icfgr has 16 fields, each field has 2bits.

    var reg: u32 = regs.reg_gic_gicd_icfgr(irq / regs.gic_gicd_icfgr_per_reg).*;

    reg &= ~((@as(u32, 0x03)) << shift); // clear the field
    reg |= ((@as(u32, config)) << shift); // set the value to the field correponding to irq
    regs.reg_gic_gicd_icfgr(irq / regs.gic_gicd_icfgr_per_reg).* = reg;
}

// send end of interrupt to irq line for gic
// @param[in] ctrlr   irq controller information
// @param[in] irq     irq number
pub fn gic_v3_eoi(irq: irq_no) void {
    gicd_clear_pending(irq);
}

// initialize gic irq controller
pub fn gic_v3_initialize() void {
    init_gicd();
    init_gicc();

    // gicd_config(aarch64.timer_irq, regs.gic_gicd_icfgr_edge);
    // gicd_set_priority(aarch64.timer_irq, 0 << aarch64.gic_pri_shift); // set priority
    // gicd_set_target(aarch64.timer_irq, 0x1); // processor 0
    // gicd_clear_pending(aarch64.timer_irq);
    // gicd_enable_int(aarch64.timer_irq);
    utils.qemuDPrint("gicv3 initialized \n");
}

// find pending irq
// @param[in]     exc  an exception frame
// @param[in,out] irqp an irq number to be processed
pub fn gic_v3_find_pending_irq(exception_frame: *ExceptionFrame, irqp: *irq_no) u32 {
    _ = exception_frame;
    var rc: u32 = undefined;
    var i: irq_no = 0;
    while (aarch64.gic_int_max > i) : (i += 1) {
        if (gicd_probe_pending(i)) {
            rc = 0;
            irqp.* = i;
            return rc;
        }
    }

    rc = 0;
    return rc;
}
