pub const aarch64 = @import("aarch64.zig");

pub const gic_gicd_base = aarch64.gic_base; // gicd mmio base address
pub const gic_gicc_base = aarch64.gic_base + 0x10000; // gicc mmio base address

pub const gic_gicd_int_per_reg = 32; // 32 interrupts per reg
pub const gic_gicd_ipriority_per_reg = 4; // 4 priority per reg
pub const gic_gicd_ipriority_size_per_reg = 8; // priority element size
pub const gic_gicd_itargetsr_core0_target_bmap = 0x01010101; // cpu interface 0
pub const gic_gicd_itargetsr_per_reg = 4;
pub const gic_gicd_itargetsr_size_per_reg = 8;
pub const gic_gicd_icfgr_per_reg = 16;
pub const gic_gicd_icfgr_size_per_reg = 2;
pub const gic_gicd_icenabler_per_reg = 32;
pub const gic_gicd_isenabler_per_reg = 32;
pub const gic_gicd_icpendr_per_reg = 32;
pub const gic_gicd_ispendr_per_reg = 32;

// 8.12 the gic cpu interface register map
pub const gic_gicc_ctlr = gic_gicc_base + 0x000; // cpu interface control register
pub const gic_gicc_pmr = gic_gicc_base + 0x004; // interrupt priority mask register
pub const gic_gicc_bpr = gic_gicc_base + 0x008; // binary point register
pub const gic_gicc_iar = gic_gicc_base + 0x00c; // interrupt acknowledge register
pub const gic_gicc_eoir = gic_gicc_base + 0x010; // end of interrupt register
pub const gic_gicc_rpr = gic_gicc_base + 0x014; // running priority register
pub const gic_gicc_hpir = gic_gicc_base + 0x018; // highest pending interrupt register
pub const gic_gicc_abpr = gic_gicc_base + 0x01c; // aliased binary point register
pub const gic_gicc_iidr = gic_gicc_base + 0x0fc; // cpu interface identification register

// 8.13.7 gicc_ctlr, cpu interface control register
pub const gicc_ctlr_enable = 0x1; // enable gicc
pub const gicc_ctlr_disable = 0x0; // disable gicc

// 8.13.14 gicc_pmr, cpu interface priority mask register
pub const gicc_pmr_prio_min = 0xff; // the lowest level mask
pub const gicc_pmr_prio_high = 0x0; // the highest level mask

// 8.13.6 gicc_bpr, cpu interface binary point register
// in systems that support only one security state, when gicc_ctlr.cbpr == 0,  this register determines only group 0 interrupt preemption.
pub const gicc_bpr_no_group = 0x0; // handle all interrupts

// 8.13.11 gicc_iar, cpu interface interrupt acknowledge register
pub const gicc_iar_intr_idmask = 0x3ff; // 0-9 bits means interrupt id
pub const gicc_iar_spurious_intr = 0x3ff; // 1023 means spurious interrupt

// 8.8 the gic distributor register map
pub const gic_gicd_ctlr = gic_gicd_base + 0x000; // distributor control register
pub const gic_gicd_type = gic_gicd_base + 0x004; // interrupt controller type register
pub const gic_gicd_iidr = gic_gicd_base + 0x008; // distributor implementer identification register
pub fn gic_gicd_igroupr(n: usize) usize {
    return gic_gicd_base + 0x080 + ((n) * 4);
}

// interrupt group registers
pub fn gic_gicd_isenabler(n: usize) usize {
    return gic_gicd_base + 0x100 + ((n) * 4);
}
// interrupt set-enable registers
pub fn gic_gicd_icenabler(n: usize) usize {
    return gic_gicd_base + 0x180 + ((n) * 4);
}
// interrupt clear-enable registers
pub fn gic_gicd_ispendr(n: usize) usize {
    return gic_gicd_base + 0x200 + ((n) * 4);
}
// interrupt set-pending registers
pub fn gic_gicd_icpendr(n: usize) usize {
    return gic_gicd_base + 0x280 + ((n) * 4);
}
// interrupt clear-pending registers
pub fn gic_gicd_isactiver(n: usize) usize {
    return gic_gicd_base + 0x300 + ((n) * 4);
}
// interrupt set-active registers
pub fn gic_gicd_icactiver(n: usize) usize {
    return gic_gicd_base + 0x380 + ((n) * 4);
}
// interrupt clear-active registers
pub fn gic_gicd_ipriorityr(n: usize) usize {
    return gic_gicd_base + 0x400 + ((n) * 4);
}
// interrupt priority registers
pub fn gic_gicd_itargetsr(n: usize) usize {
    return gic_gicd_base + 0x800 + ((n) * 4);
}
// interrupt processor targets registers
pub fn gic_gicd_icfgr(n: usize) usize {
    return gic_gicd_base + 0xc00 + ((n) * 4);
}
// interrupt configuration registers
pub fn gic_gicd_nscar(n: usize) usize {
    return gic_gicd_base + 0xe00 + ((n) * 4);
}
// non-secure access control registers
pub const gic_gicd_sgir = (gic_gicd_base + 0xf00);
// software generated interrupt register
pub fn gic_gicd_cpendsgir(n: usize) usize {
    return gic_gicd_base + 0xf10 + ((n) * 4);
}
// sgi clear-pending registers
pub fn gic_gicd_spendsgir(n: usize) usize {
    return gic_gicd_base + 0xf20 + ((n) * 4);
}
// sgi set-pending registers

// 8.9.4 gicd_ctlr, distributor control register
pub const gic_gicd_ctlr_enable = (0x1); // enable gicd
pub const gic_gicd_ctlr_disable = (0x0); // disable gicd

// 8.9.7 gicd_icfgr<n>, interrupt configuration registers
pub const gic_gicd_icfgr_level = (0x0); // level-sensitive
pub const gic_gicd_icfgr_edge = (0x2); // edge-triggered

// register access macros for gicc
pub const reg_gic_gicc_ctlr = @intToPtr(*volatile u32, gic_gicc_ctlr);
pub const reg_gic_gicc_pmr = @intToPtr(*volatile u32, gic_gicc_pmr);
pub const reg_gic_gicc_bpr = @intToPtr(*volatile u32, gic_gicc_bpr);
pub const reg_gic_gicc_iar = @intToPtr(*volatile u32, gic_gicc_iar);
pub const reg_gic_gicc_eoir = @intToPtr(*volatile u32, gic_gicc_eoir);
pub const reg_gic_gicc_rpr = @intToPtr(*volatile u32, gic_gicc_rpr);
pub const reg_gic_gicc_hpir = @intToPtr(*volatile u32, gic_gicc_hpir);
pub const reg_gic_gicc_abpr = @intToPtr(*volatile u32, gic_gicc_abpr);
pub const reg_gic_gicc_iidr = @intToPtr(*volatile u32, gic_gicc_iidr);

// register access macros for gicd
pub const reg_gic_gicd_ctlr = @intToPtr(*volatile u32, gic_gicd_ctlr);
pub const reg_gic_gicd_type = @intToPtr(*volatile u32, gic_gicd_type);
pub const reg_gic_gicd_iidr = @intToPtr(*volatile u32, gic_gicd_iidr);

pub const reg_gic_gicd_sgir = @intToPtr(*volatile u32, gic_gicd_sgir);

pub fn reg_gic_gicd_igroupr(n: usize) *volatile u32 {
    return @intToPtr(*volatile u32, gic_gicd_igroupr(n));
}
pub fn reg_gic_gicd_isenabler(n: usize) *volatile u32 {
    return @intToPtr(*volatile u32, gic_gicd_isenabler(n));
}
pub fn reg_gic_gicd_icenabler(n: usize) *volatile u32 {
    return @intToPtr(*volatile u32, gic_gicd_icenabler(n));
}
pub fn reg_gic_gicd_ispendr(n: usize) *volatile u32 {
    return @intToPtr(*volatile u32, gic_gicd_ispendr(n));
}
pub fn reg_gic_gicd_icpendr(n: usize) *volatile u32 {
    return @intToPtr(*volatile u32, gic_gicd_icpendr(n));
}
pub fn reg_gic_gicd_isactiver(n: usize) *volatile u32 {
    return @intToPtr(*volatile u32, gic_gicd_isactiver(n));
}
pub fn reg_gic_gicd_icactiver(n: usize) *volatile u32 {
    return @intToPtr(*volatile u32, gic_gicd_icactiver(n));
}
pub fn reg_gic_gicd_ipriorityr(n: usize) *volatile u32 {
    return @intToPtr(*volatile u32, gic_gicd_ipriorityr(n));
}
pub fn reg_gic_gicd_itargetsr(n: usize) *volatile u32 {
    return @intToPtr(*volatile u32, gic_gicd_itargetsr(n));
}
pub fn reg_gic_gicd_icfgr(n: usize) *volatile u32 {
    return @intToPtr(*volatile u32, gic_gicd_icfgr(n));
}
pub fn reg_gic_gicd_nscar(n: usize) *volatile u32 {
    return @intToPtr(*volatile u32, gic_gicd_nscar(n));
}
pub fn reg_gic_gicd_cpendsgir(n: usize) *volatile u32 {
    return @intToPtr(*volatile u32, gic_gicd_cpendsgir(n));
}
pub fn reg_gic_gicd_spendsgir(n: usize) *volatile u32 {
    return @intToPtr(*volatile u32, gic_gicd_spendsgir(n));
}
