const aarch64 = @import("aarch64.zig");

const psw_t: type = u64; // Processor status word

// Disable interrupt at CPU level
// @ param [in] pswp Processor status word return area before interrupt disabled
fn psw_disable_and_save_interrupt(pswp: *psw_t) void {
    var psw: psw_t = undefined;

    // save psw
    psw = aarch64.raw_read_daif();
    aarch64.enable_irq();
    pswp.* = psw;
}

// Restore interrupt status at CPU level
// @ param [in] pswp Processor status word return area
fn psw_restore_interrupt(pswp: *psw_t) void {
    var psw: psw_t = undefined;

    psw = *pswp;
    aarch64.raw_write_daif(psw);
}
