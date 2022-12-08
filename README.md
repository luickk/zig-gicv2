# Zig gicv2

This repository contains a basic generic interrupt controller for aarch64, specifically the a57 (tested with qemu). gicv2 docs can be found [here](https://developer.arm.com/documentation/ihi0069/latest).

## Example Arm Timer Interrupt

```zig
	// disabling & clearing all pending irqs, setting all irqs to lowest priority, setting target core to 0
	// enabling gicc and gicd
	try Gic.init();

	// setting timer irq to edge-triggered(0x2)
	try Gic.Gicd.gicdConfig(Gic.InterruptIds.non_secure_physical_timer, 0x2);
	// setting timer irq to highest priority 0
	try Gic.Gicd.gicdSetPriority(Gic.InterruptIds.non_secure_physical_timer, 0);
	// setting target to core 0 (1 for the register write)
	try Gic.Gicd.gicdSetTarget(Gic.InterruptIds.non_secure_physical_timer, 1);
	// clearing if pending so that new vector table call can be invoked
	try Gic.Gicd.gicdClearPending(Gic.InterruptIds.non_secure_physical_timer);
	// finally enabling timer interrupt
	try Gic.Gicd.gicdEnableInt(Gic.InterruptIds.non_secure_physical_timer);
```