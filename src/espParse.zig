pub const EspReg = union {
    val: u64,
    parts: struct {
        // Instruction Specific Syndrome [24:0]
        iss: u25,
        //  Condition code valid [24]
        cv: u1,
        // Instruction Length for synchronous exceptions [25]
        il: u1,
        // exception class [31:26]
        ec: u6,
        _: u31,
    },
};

pub const ExceptionClass = enum(u6) {
    unknownReason = 0b000000,
    trappedWF = 0b000001,
    trappedMCR = 0b000011,
    trappedMcrr = 0b000100,
    trappedMCRWithAcc = 0b000101,
    trappedLdcStcAcc = 0b000110,
    sveAsmidFpAcc = 0b000111,
    trappedLdStInst = 0b001010,
    trappedMrrcWithAcc = 0b001100,
    branchTargetExc = 0b001101,
    illegalExecState = 0b001110,
    svcInstExcAArch32 = 0b010001,
    svcInstExAArch64 = 0b010101,
    trappedMsrMrsSiAarch64 = 0b011000,
    sveFuncTrappedAcc = 0b011001,
    excFromPointerAuthInst = 0b011100,
    instAbortFromLowerExcLvl = 0b100000,
    instAbortTakenWithoutExcLvlChange = 0b100001,
    pcAlignFaultExc = 0b100010,
    dataAbortFromLowerExcLvl = 0b100100,
    dataAbortWithoutExcLvlChange = 0b100101,
    spAlignmentFaultExc = 0b100110,
    trappedFpExcAarch32 = 0b101000,
    trappedFpExcAarch64 = 0b101100,
    brkPExcFromLowerExcLvl = 0b101111,
    brkPExcWithoutExcLvlChg = 0b110001,
    softwStepExcpFromLowerExcLvl = 0b110010,
    softwStepExcTakenWithoutExcLvlChange = 0b110011,
    watchPointExcpFromALowerExcLvl = 0b110100,
    watchPointExcpWithoutTakenWithoutExcLvlChange = 0b110101,
    bkptInstExecAarch32 = 0b111000,
    bkptInstExecAarch64 = 0b111100,
};