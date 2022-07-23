const irHandle = @import("irHandle.zig");

pub const psw_t: type = u64; // Processor status word

// Disable interrupt at CPU level
// @ param [in] pswp Processor status word return area before interrupt disabled
pub fn psw_disable_and_save_interrupt(pswp: *psw_t) void {
    var psw: psw_t = undefined;

    // save psw
    psw = irHandle.raw_read_daif();
    irHandle.enable_irq();
    pswp.* = psw;
}

// Restore interrupt status at CPU level
// @ param [in] pswp Processor status word return area
pub fn psw_restore_interrupt(pswp: *psw_t) void {
    var psw: psw_t = undefined;

    psw = pswp.*;
    irHandle.raw_write_daif(@truncate(u32, psw));
}
