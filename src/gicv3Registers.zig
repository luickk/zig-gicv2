const aarch64 = @import("aarch64.zig");

const gic_gicd_base = aarch64.gic_base; // gicd mmio base address
const gic_gicc_base = aarch64.gic_base + 0x10000; // gicc mmio base address

const gic_gicd_int_per_reg = 32; // 32 interrupts per reg
const gic_gicd_ipriority_per_reg = 4; // 4 priority per reg
const gic_gicd_ipriority_size_per_reg = 8; // priority element size
const gic_gicd_itargetsr_core0_target_bmap = 0x01010101; // cpu interface 0
const gic_gicd_itargetsr_per_reg = 4;
const gic_gicd_itargetsr_size_per_reg = 8;
const gic_gicd_icfgr_per_reg = 16;
const gic_gicd_icfgr_size_per_reg = 2;
const gic_gicd_icenabler_per_reg = 32;
const gic_gicd_isenabler_per_reg = 32;
const gic_gicd_icpendr_per_reg = 32;
const gic_gicd_ispendr_per_reg = 32;

// 8.12 the gic cpu interface register map
const gic_gicc_ctlr = gic_gicc_base + 0x000; // cpu interface control register
const gic_gicc_pmr = gic_gicc_base + 0x004; // interrupt priority mask register
const gic_gicc_bpr = gic_gicc_base + 0x008; // binary point register
const gic_gicc_iar = gic_gicc_base + 0x00c; // interrupt acknowledge register
const gic_gicc_eoir = gic_gicc_base + 0x010; // end of interrupt register
const gic_gicc_rpr = gic_gicc_base + 0x014; // running priority register
const gic_gicc_hpir = gic_gicc_base + 0x018; // highest pending interrupt register
const gic_gicc_abpr = gic_gicc_base + 0x01c; // aliased binary point register
const gic_gicc_iidr = gic_gicc_base + 0x0fc; // cpu interface identification register

// 8.13.7 gicc_ctlr, cpu interface control register
const gicc_ctlr_enable = 0x1; // enable gicc
const gicc_ctlr_disable = 0x0; // disable gicc

// 8.13.14 gicc_pmr, cpu interface priority mask register
const gicc_pmr_prio_min = 0xff; // the lowest level mask
const gicc_pmr_prio_high = 0x0; // the highest level mask

// 8.13.6 gicc_bpr, cpu interface binary point register
// in systems that support only one security state, when gicc_ctlr.cbpr == 0,  this register determines only group 0 interrupt preemption.
const gicc_bpr_no_group = 0x0; // handle all interrupts

// 8.13.11 gicc_iar, cpu interface interrupt acknowledge register
const gicc_iar_intr_idmask = 0x3ff; // 0-9 bits means interrupt id
const gicc_iar_spurious_intr = 0x3ff; // 1023 means spurious interrupt

// 8.8 the gic distributor register map
const gic_gicd_ctlr = gic_gicd_base + 0x000; // distributor control register
const gic_gicd_type = gic_gicd_base + 0x004; // interrupt controller type register
const gic_gicd_iidr = gic_gicd_base + 0x008; // distributor implementer identification register
fn gic_gicd_igroupr(n: usize) usize {
    return gic_gicd_base + 0x080 + ((n) * 4);
} // interrupt group registers
fn gic_gicd_isenabler(n: usize) usize {
    return gic_gicd_base + 0x100 + ((n) * 4);
} // interrupt set-enable registers
fn gic_gicd_icenabler(n: usize) usize {
    return gic_gicd_base + 0x180 + ((n) * 4);
} // interrupt clear-enable registers
fn gic_gicd_ispendr(n: usize) usize {
    return gic_gicd_base + 0x200 + ((n) * 4);
} // interrupt set-pending registers
fn gic_gicd_icpendr(n: usize) usize {
    return gic_gicd_base + 0x280 + ((n) * 4);
} // interrupt clear-pending registers
fn gic_gicd_isactiver(n: usize) usize {
    return gic_gicd_base + 0x300 + ((n) * 4);
} // interrupt set-active registers
fn gic_gicd_icactiver(n: usize) usize {
    return gic_gicd_base + 0x380 + ((n) * 4);
} // interrupt clear-active registers
fn gic_gicd_ipriorityr(n: usize) usize {
    return gic_gicd_base + 0x400 + ((n) * 4);
} // interrupt priority registers
fn gic_gicd_itargetsr(n: usize) usize {
    return gic_gicd_base + 0x800 + ((n) * 4);
} // interrupt processor targets registers
fn gic_gicd_icfgr(n: usize) usize {
    return gic_gicd_base + 0xc00 + ((n) * 4);
} // interrupt configuration registers
fn gic_gicd_nscar(n: usize) usize {
    return gic_gicd_base + 0xe00 + ((n) * 4);
} // non-secure access control registers
const gic_gicd_sgir = (gic_gicd_base + 0xf00); // software generated interrupt register
fn gic_gicd_cpendsgir(n: usize) usize {
    return gic_gicd_base + 0xf10 + ((n) * 4);
} // sgi clear-pending registers
fn gic_gicd_spendsgir(n: usize) usize {
    return gic_gicd_base + 0xf20 + ((n) * 4);
} // sgi set-pending registers

// 8.9.4 gicd_ctlr, distributor control register
const gic_gicd_ctlr_enable = (0x1); // enable gicd
const gic_gicd_ctlr_disable = (0x0); // disable gicd

// 8.9.7 gicd_icfgr<n>, interrupt configuration registers
const gic_gicd_icfgr_level = (0x0); // level-sensitive
const gic_gicd_icfgr_edge = (0x2); // edge-triggered

// register access macros for gicc
const reg_gic_gicc_ctlr = @ptrCast(*volatile u32, gic_gicc_ctlr);
const reg_gic_gicc_pmr = @ptrCast(*volatile u32, gic_gicc_pmr);
const reg_gic_gicc_bpr = @ptrCast(*volatile u32, gic_gicc_bpr);
const reg_gic_gicc_iar = @ptrCast(*volatile u32, gic_gicc_iar);
const reg_gic_gicc_eoir = @ptrCast(*volatile u32, gic_gicc_eoir);
const reg_gic_gicc_rpr = @ptrCast(*volatile u32, gic_gicc_rpr);
const reg_gic_gicc_hpir = @ptrCast(*volatile u32, gic_gicc_hpir);
const reg_gic_gicc_abpr = @ptrCast(*volatile u32, gic_gicc_abpr);
const reg_gic_gicc_iidr = @ptrCast(*volatile u32, gic_gicc_iidr);

// register access macros for gicd
const reg_gic_gicd_ctlr = @ptrCast(*volatile u32, gic_gicd_ctlr);
const reg_gic_gicd_type = @ptrCast(*volatile u32, gic_gicd_type);
const reg_gic_gicd_iidr = @ptrCast(*volatile u32, gic_gicd_iidr);

const reg_gic_gicd_sgir = @ptrCast(*volatile u32, gic_gicd_sgir);

fn reg_gic_gicd_igroupr(n: usize) *volatile u32 {
    return @ptrCast(*volatile u32, gic_gicd_igroupr(n));
}
fn reg_gic_gicd_isenabler(n: usize) *volatile u32 {
    return @ptrCast(*volatile u32, gic_gicd_isenabler(n));
}
fn reg_gic_gicd_icenabler(n: usize) *volatile u32 {
    return @ptrCast(*volatile u32, gic_gicd_icenabler(n));
}
fn reg_gic_gicd_ispendr(n: usize) *volatile u32 {
    return @ptrCast(*volatile u32, gic_gicd_ispendr(n));
}
fn reg_gic_gicd_icpendr(n: usize) *volatile u32 {
    return @ptrCast(*volatile u32, gic_gicd_icpendr(n));
}
fn reg_gic_gicd_isactiver(n: usize) *volatile u32 {
    return @ptrCast(*volatile u32, gic_gicd_isactiver(n));
}
fn reg_gic_gicd_icactiver(n: usize) *volatile u32 {
    return @ptrCast(*volatile u32, gic_gicd_icactiver(n));
}
fn reg_gic_gicd_ipriorityr(n: usize) *volatile u32 {
    return @ptrCast(*volatile u32, gic_gicd_ipriorityr(n));
}
fn reg_gic_gicd_itargetsr(n: usize) *volatile u32 {
    return @ptrCast(*volatile u32, gic_gicd_itargetsr(n));
}
fn reg_gic_gicd_icfgr(n: usize) *volatile u32 {
    return @ptrCast(*volatile u32, gic_gicd_icfgr(n));
}
fn reg_gic_gicd_nscar(n: usize) *volatile u32 {
    return @ptrCast(*volatile u32, gic_gicd_nscar(n));
}
fn reg_gic_gicd_cpendsgir(n: usize) *volatile u32 {
    return @ptrCast(*volatile u32, gic_gicd_cpendsgir(n));
}
fn reg_gic_gicd_spendsgir(n: usize) *volatile u32 {
    return @ptrCast(*volatile u32, gic_gicd_spendsgir(n));
}
