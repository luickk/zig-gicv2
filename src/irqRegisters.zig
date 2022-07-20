// vector table see 5.1.1 setting up a vector table in application note bare-metal boot code for armv8-a processors version 1.0

// aarch64 exception types
// current el with sp0
const aarch64_exc_sync_sp0 = 0x1; // synchronous
const aarch64_exc_irq_sp0 = 0x2; // irq/virq
const aarch64_exc_fiq_sp0 = 0x3; // fiq/vfiq
const aarch64_exc_serr_sp0 = 0x4; // serror/vserror
// current el with spx
const aarch64_exc_sync_spx = 0x11;
const aarch64_exc_irq_spx = 0x12;
const aarch64_exc_fiq_spx = 0x13;
const aarch64_exc_serr_spx = 0x14;
// lower el using aarch64
const aarch64_exc_sync_aarch64 = 0x21;
const aarch64_exc_irq_aarch64 = 0x22;
const aarch64_exc_fiq_aarch64 = 0x23;
const aarch64_exc_serr_aarch64 = 0x24;
// lower el using aarch32
const aarch64_exc_sync_aarch32 = 0x31;
const aarch64_exc_irq_aarch32 = 0x32;
const aarch64_exc_fiq_aarch32 = 0x33;
const aarch64_exc_serr_aarch32 = 0x34;

// #if defined(asm_file)
const vector_table_align = 11; // vector tables must be placed at a 2kb-aligned address
const vector_entry_align = 7; // each entry is 128b in size
const text_align = 2; // text alignment

// exception_frame offset definitions
const exc_frame_size = 288; // sizeof(struct _exception_frame)
const exc_exc_type_offset = 0; // __asm_offsetof(struct _exception_frame, exc_type)
const exc_exc_esr_offset = 8; // __asm_offsetof(struct _exception_frame, exc_esr)
const exc_exc_sp_offset = 16; // __asm_offsetof(struct _exception_frame, exc_sp)
const exc_exc_elr_offset = 24; // __asm_offsetof(struct _exception_frame, exc_elr)
const exc_exc_spsr_offset = 32; // __asm_offsetof(struct _exception_frame, exc_spsr)
