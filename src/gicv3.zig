const regs = @import("gicv3Registers.zig");
const GiccRegMap = regs.GiccRegMap;
const GicdRegMap = regs.GicdRegMap;

const utils = @import("utils.zig");

// todo => consider removing extra type for irqNo. no need for obscuring...
pub const irqNo: type = u32;

// initialize gic irq controller
pub fn gicV3Initialize() void {
    Gicc.init();
    Gicd.init();

    utils.qemuDPrint("gicv3 initialized \n");
}

// reads interrupt data placed by exc. vec from the stack
pub const ExceptionFrame = extern struct {
    regs: [30]u64,
    elr_el1: u64,
    esr_el1: u64,
    spsr_el1: u64,
    lr: u64,
};

pub const Gicc = struct {
    // initialize gic controller
    fn init() void {
        // disable cpu interface
        GiccRegMap.ctlr.* = regs.gicc_ctlr_disable;

        // set the priority level as the lowest priority
        // note: higher priority corresponds to a lower priority field value in the gic_pmr.
        // in addition to this, writing 255 to the gicc_pmr always sets it to the largest supported priority field value.
        GiccRegMap.pmr.* = regs.gicc_pmr_prio_min;

        // handle all of interrupts in a single group
        GiccRegMap.bpr.* = regs.gicc_bpr_no_group;

        // clear all of the active interrupts
        var pending_irq: u32 = 0;
        while (pending_irq != regs.gicc_iar_spurious_intr) : (pending_irq = GiccRegMap.iar.* & regs.gicc_iar_spurious_intr) {
            // pending_irq = ( *reg_gic_gicc_iar & gicc_iar_intr_idmask ) )
            GiccRegMap.eoir.* = GiccRegMap.eoir.*;
        }

        // enable cpu interface
        GiccRegMap.ctlr.* = regs.gicc_ctlr_enable;
    }

    // send end of interrupt to irq line for gic
    // @param[in] ctrlr   irq controller information
    // @param[in] irq     irq number
    pub fn gicV3Eoi(irq: irqNo) void {
        Gicd.gicdClearPending(irq);
    }

    // find pending irq
    // @param[in]     exc  an exception frame
    // @param[in,out] irqp an irq number to be processed
    pub fn gicV3FindPendingIrq(exception_frame: *ExceptionFrame, irqp: *irqNo) u32 {
        _ = exception_frame;
        var rc: u32 = undefined;
        var i: irqNo = 0;
        while (regs.gic_int_max > i) : (i += 1) {
            if (Gicd.gicdProbePending(i)) {
                rc = 0;
                irqp.* = i;
                return rc;
            }
        }

        rc = 0;
        return rc;
    }
};

pub const Gicd = struct {
    // init the gic distributor
    fn init() void {
        var i: u32 = 0;
        var regs_nr: u32 = 0;

        // utils.qemuDPrint("init_gicd()\n");
        // diable distributor
        GicdRegMap.ctlr.* = regs.gicd_ctlr_disable;

        // disable all irqs
        regs_nr = (regs.gic_int_max + regs.gicd_int_per_reg - 1) / regs.gicd_int_per_reg;
        while (regs_nr > i) : (i += 1) {
            GicdRegMap.calcReg(GicdRegMap.icenabler, i).* = ~@as(u32, 0);
        }
        i = 0;

        // clear all pending irqs
        regs_nr = (regs.gic_int_max + regs.gicd_int_per_reg - 1) / regs.gicd_int_per_reg;
        while (regs_nr > i) : (i += 1) {
            GicdRegMap.calcReg(GicdRegMap.icpendr, i).* = ~@as(u32, 0);
        }
        i = 0;

        // set all of interrupt priorities as the lowest priority
        regs_nr = (regs.gic_int_max + regs.gicd_ipriority_per_reg - 1) / regs.gicd_ipriority_per_reg;
        while (regs_nr > i) : (i += 1) {
            GicdRegMap.calcReg(GicdRegMap.ipriorityr, i).* = ~@as(u32, 0);
        }
        i = 0;

        // set target of all of shared peripherals to processor 0
        i = regs.gic_intno_spi0 / regs.gicd_itargetsr_per_reg;
        while ((regs.gic_int_max + (regs.gicd_itargetsr_per_reg - 1)) / regs.gicd_itargetsr_per_reg > i) : (i += 1) {
            GicdRegMap.calcReg(GicdRegMap.itargetsr, i).* = @as(u32, regs.gicd_itargetsr_core0_target_bmap);
        }

        // set trigger type for all peripheral interrupts level triggered
        i = regs.gic_intno_ppi0 / regs.gicd_icfgr_per_reg;
        while ((regs.gic_int_max + (regs.gicd_icfgr_per_reg - 1)) / regs.gicd_icfgr_per_reg > i) : (i += 1) {
            GicdRegMap.calcReg(GicdRegMap.icfgr, i).* = regs.gicd_icfgr_level;
        }

        // enable distributor
        GicdRegMap.ctlr.* = regs.gicd_ctlr_enable;
    }

    // disable irq
    // @param[in] irq irq number
    pub fn gicdDisableInt(irq: irqNo) void {
        GicdRegMap.calcReg(GicdRegMap.icenabler, irq / regs.gicd_icenabler_per_reg).* = @as(u8, 1) << @truncate(u3, irq % regs.gicd_icenabler_per_reg);
    }

    // enable irq
    // @param[in] irq irq number
    pub fn gicdEnableInt(irq: irqNo) void {
        GicdRegMap.calcReg(GicdRegMap.isenabler, irq / regs.gicd_isenabler_per_reg).* = @as(u8, 1) << @truncate(u3, irq % regs.gicd_isenabler_per_reg);
    }

    // clear a pending interrupt
    // @param[in] irq irq number
    fn gicdClearPending(irq: irqNo) void {
        GicdRegMap.calcReg(GicdRegMap.icpendr, irq / regs.gicd_icpendr_per_reg).* = @as(u8, 1) << @truncate(u3, irq % regs.gicd_icpendr_per_reg);
    }

    // probe pending interrupt
    // @param[in] irq irq number
    fn gicdProbePending(irq: irqNo) bool {
        var is_pending = (GicdRegMap.calcReg(GicdRegMap.ispendr, (irq / regs.gicd_ispendr_per_reg)).* & (@as(u8, 1) << @truncate(u3, irq % regs.gicd_ispendr_per_reg)));
        return is_pending != 0;
    }

    // set an interrupt target processor
    // @param[in] irq irq number
    // @param[in] p   target processor mask
    // 0x1 processor 0
    // 0x2 processor 1
    // 0x4 processor 2
    // 0x8 processor 3
    fn gicdSetTarget(irq: irqNo, p: u32) void {
        var shift: u5 = @truncate(u5, (irq % regs.gic_gicd_itargetsr_per_reg) * regs.gic_gicd_itargetsr_size_per_reg);

        var reg: u32 = regs.reg_gic_gicd_itargetsr(irq / regs.gic_gicd_itargetsr_per_reg).*;
        reg &= ~(@as(u32, 0xff) << shift);
        reg |= p << shift;
        regs.reg_gic_gicd_itargetsr(irq / regs.gic_gicd_itargetsr_per_reg).* = reg;
    }

    // set an interrupt priority
    // @param[in] irq  irq number
    // @param[in] prio interrupt priority in arm specific expression
    fn gicdSetPriority(irq: irqNo, prio: u32) void {
        var shift: u5 = @truncate(u5, (irq % regs.gic_gicd_ipriority_per_reg) * regs.gic_gicd_ipriority_size_per_reg);
        var reg: u32 = regs.reg_gic_gicd_ipriorityr(irq / regs.gic_gicd_ipriority_per_reg).*;
        reg &= ~(@as(u32, 0xff) << shift);
        reg |= (prio << shift);
        regs.reg_gic_gicd_ipriorityr(irq / regs.gic_gicd_ipriority_per_reg).* = reg;
    }

    // configure irq
    // @param[in] irq     irq number
    // @param[in] config  configuration value for gicd_icfgr
    fn gicdConfig(irq: irqNo, config: u32) void {
        var shift: u5 = @truncate(u5, (irq % regs.gic_gicd_icfgr_per_reg) * regs.gic_gicd_icfgr_size_per_reg); // gicd_icfgr has 17 fields, each field has 2bits.

        var reg: u32 = regs.reg_gic_gicd_icfgr(irq / regs.gic_gicd_icfgr_per_reg).*;

        reg &= ~((@as(u32, 0x03)) << shift); // clear the field
        reg |= ((@as(u32, config)) << shift); // set the value to the field correponding to irq
        regs.reg_gic_gicd_icfgr(irq / regs.gic_gicd_icfgr_per_reg).* = reg;
    }
};
