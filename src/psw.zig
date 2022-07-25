const intHandle = @import("intHandle.zig");

// Disable interrupt at CPU level
// @ param [in] pswp Processor status word return area before interrupt disabled
pub fn pswDisableAndSaveInterrupt(pswp: *u64) void {
    var psw: u64 = undefined;

    // save psw
    psw = intHandle.raw_read_daif();
    intHandle.disable_irq();
    pswp.* = psw;
}

// Restore interrupt status at CPU level
// @ param [in] pswp Processor status word return area
pub fn psw_restore_interrupt(pswp: *u64) void {
    var psw: u64 = undefined;

    psw = pswp.*;
    intHandle.raw_write_daif(@truncate(u32, psw));
}
