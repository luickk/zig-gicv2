// gic
pub const qemu_virt_gic_base = 0x08000000;
pub const qemu_virt_gic_int_max = 64;
pub const qemu_virt_gic_intno_spio = 32;
pub const qemu_virt_gic_intno_ppio = 16;

pub const gic_base = qemu_virt_gic_base;
pub const gic_int_max = qemu_virt_gic_int_max;
pub const gic_pri_shift = 4;
pub const gic_intno_ppi0 = qemu_virt_gic_intno_ppio;

pub const gic_intno_spi0 = qemu_virt_gic_intno_spio;
pub const gic_gicd_base = gic_base; // gicd mmio base address
pub const gic_gicc_base = gic_base + 0x10000; // gicc mmio base address

// gicd..
// 8.9.4 gicd_ctlr, distributor control register
pub const gicd_ctlr_enable = 0x1; // enable gicd
pub const gicd_ctlr_disable = 0; // disable gicd

// 8.9.7 gicd_icfgr<n>, interrupt configuration registers
pub const gicd_icfgr_level = 0; // level-sensitive
pub const gicd_icfgr_edge = 0x2; // edge-triggered
// non-secure access control registers

// 8.13.14 gicc_pmr, cpu interface priority mask register
pub const gicc_pmr_prio_min = gic_gicc_base + 0xff; // the lowest level mask
pub const gicc_pmr_prio_high = gic_gicc_base + 0x0; // the highest level mask
// 8.13.7 gicc_ctlr, cpu interface control register
pub const gicc_ctlr_enable = 0x1; // enable gicc
pub const gicc_ctlr_disable = 0x0; // disable gicc
// 8.13.6 gicc_bpr, cpu interface binary point register
// in systems that support only one security state, when gicc_ctlr.cbpr == 0,  this register determines only group 0 interrupt preemption.
pub const gicc_bpr_no_group = 0x0; // handle all interrupts
// 8.13.11 gicc_iar, cpu interface interrupt acknowledge register
pub const gicc_iar_intr_idmask = 0x3ff; // 0-9 bits means interrupt id
pub const gicc_iar_spurious_intr = 0x3ff; // 1023 means spurious interrupt

// 8.12 the gic cpu interface register map
pub const GiccRegMap = struct {
    pub const ctlr = @intToPtr(*volatile u32, gic_gicc_base + 0x000); // cpu interface control register
    pub const pmr = @intToPtr(*volatile u32, gic_gicc_base + 0x004); // interrupt priority mask register
    pub const bpr = @intToPtr(*volatile u32, gic_gicc_base + 0x008); // binary point register
    pub const iar = @intToPtr(*volatile u32, gic_gicc_base + 0x00c); // interrupt acknowledge register
    pub const eoir = @intToPtr(*volatile u32, gic_gicc_base + 0x010); // end of interrupt register
    pub const rpr = @intToPtr(*volatile u32, gic_gicc_base + 0x014); // running priority register
    pub const hpir = @intToPtr(*volatile u32, gic_gicc_base + 0x018); // highest pending interrupt register
    pub const abpr = @intToPtr(*volatile u32, gic_gicc_base + 0x01c); // aliased binary point register
    pub const iidr = @intToPtr(*volatile u32, gic_gicc_base + 0x0fc); // cpu interface identification register
};

// gicc...
pub const gicd_itargetsr_per_reg = 4;
pub const gicd_itargetsr_size_per_reg = 8;
pub const gicd_icfgr_per_reg = 16;
pub const gicd_icfgr_size_per_reg = 2;
pub const gicd_icenabler_per_reg = 32;
pub const gicd_isenabler_per_reg = 32;
pub const gicd_icpendr_per_reg = 32;
pub const gicd_ispendr_per_reg = 32;
pub const gicd_int_per_reg = 32; // 32 interrupts per reg
pub const gicd_ipriority_per_reg = 4; // 4 priority per reg
pub const gicd_ipriority_size_per_reg = 8; // priority element size
pub const gicd_itargetsr_core0_target_bmap = 0x01010101; // cpu interface 0

// 8.8 The GIC Distributor register map
pub const GicdRegMap = struct {
    pub const ctlr = @intToPtr(*volatile u32, gic_gicc_base + 0x0); // distributor control register
    pub const intType = @intToPtr(*volatile u32, gic_gicc_base + 0x004); // interrupt controller type register
    pub const iidr = @intToPtr(*volatile u32, gic_gicc_base + 0x008); // distributor implementer identification register
    pub const igroupr = @intToPtr(*volatile u32, gic_gicc_base + 0x080); // interrupt group registers
    pub const isenabler = @intToPtr(*volatile u32, gic_gicc_base + 0x100); // interrupt set-enable registers
    pub const icenabler = @intToPtr(*volatile u32, gic_gicc_base + 0x180); // interrupt clear-enable registers
    pub const ispendr = @intToPtr(*volatile u32, gic_gicc_base + 0x200); // interrupt set-pending registers
    pub const icpendr = @intToPtr(*volatile u32, gic_gicc_base + 0x280); // interrupt clear-pending registers
    pub const isactiver = @intToPtr(*volatile u32, gic_gicc_base + 0x300); // interrupt set-active registers
    pub const icactiver = @intToPtr(*volatile u32, gic_gicc_base + 0x380); // interrupt clear-active registers
    pub const ipriorityr = @intToPtr(*volatile u32, gic_gicc_base + 0x400); //  interrupt priority registers
    pub const itargetsr = @intToPtr(*volatile u32, gic_gicc_base + 0x800); // interrupt processor targets registers
    pub const icfgr = @intToPtr(*volatile u32, gic_gicc_base + 0xc00); // interrupt configuration registers
    pub const nscar = @intToPtr(*volatile u32, gic_gicc_base + 0xe00); // software generated interrupt register
    pub const cpendsgir = @intToPtr(*volatile u32, gic_gicc_base + 0xf10); // sgi clear-pending registers
    pub const spendsgir = @intToPtr(*volatile u32, gic_gicc_base + 0xf20); // sgi set-pending registers
    pub const sgir = @intToPtr(*volatile u32, 0xf00);

    pub fn calcReg(offset: *volatile u32, n: usize) *volatile u32 {
        return @intToPtr(*volatile u32, gic_gicd_base + @as(usize, @ptrToInt(offset)) + (n * 4));
    }
};
