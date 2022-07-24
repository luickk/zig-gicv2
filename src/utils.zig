pub const PrintStyle = enum(u8) {
    string = 10,
    hex = 16,
    binary = 2,
};

fn exception_svc() void {
    // Supervisor call to allow application code to call the OS.  It generates an exception targeting exception level 1 (EL1).
    asm volatile ("svc #0xdead");
}

// main
pub fn exception_svc_test() void {
    qemuDPrint("exception_svc_test... start\n");
    // SVC instruction causes a Supervisor Call exception.
    // vector_table:_curr_el_spx_sync should be called
    exception_svc();

    // Wait for Interrupt.
    // asm volatile ("wfi" ::: "memory");
    qemuDPrint("exception_svc_test... done\n");
}

const mmio_uart = @intToPtr(*volatile u8, 0x09000000);
fn putChar(ch: u8) void {
    mmio_uart.* = ch;
}

pub fn reverseString(str: [*]u8, len: usize) void {
    var start: usize = 0;
    var end: usize = len - 1;
    var temp: u8 = 0;

    while (end > start) {
        temp = str[start];
        str[start] = str[end];
        str[end] = temp;

        start += 1;
        end -= 1;
    }
}
pub fn qemuDPrint(comptime print_string: []const u8) void {
    for (print_string) |ch| {
        putChar(ch);
    }
}

pub fn qemuUintPrint(num: u64, print_style: PrintStyle) void {
    var str = [_]u8{0} ** 20;

    if (num == 0) {
        str[0] = 0;
        return;
    }

    var rem: u64 = 0;
    var i: u8 = 0;
    var num_i = num;
    while (num_i != 0) {
        rem = @mod(num_i, @enumToInt(print_style));
        if (rem > 9) {
            str[i] = @truncate(u8, (rem - 10) + 'a');
        } else {
            str[i] = @truncate(u8, rem + '0');
        }
        i += 1;

        num_i = num_i / @enumToInt(print_style);
    }
    reverseString(&str, i);

    var j: usize = 0;
    while (j < i) : (j += 1) {
        putChar(str[j]);
    }
}

// from zigs std lib
pub const IntToEnumError = error{InvalidEnumTag};
pub fn intToEnum(comptime EnumTag: type, tag_int: anytype) IntToEnumError!EnumTag {
    inline for (@typeInfo(EnumTag).Enum.fields) |f| {
        const this_tag_value = @field(EnumTag, f.name);
        if (tag_int == @enumToInt(this_tag_value)) {
            return this_tag_value;
        }
    }
    return error.InvalidEnumTag;
}
