/// Encodes little-endian
pub fn encode(message: anytype, comptime size: usize) [size]u8 {
    var bytes: [size]u8 = undefined;

    const T = @TypeOf(message);
    const t_info = @typeInfo(T);

    switch (t_info) {
        .Struct => |s| {
            switch (s.layout) {
                .@"packed" => {},
                else => @compileError("Struct must be packed to encode"),
            }
        },
        else => @compileError("Only structs can be encoded"),
    }

    if ((size * 8) < @bitSizeOf(T)) @compileError("Encoding buffer size too small");

    var buffer: u8 = 0;
    var current_bit: u3 = 0;
    var current_byte: usize = 0;

    inline for (t_info.Struct.fields) |field| {
        const field_info = @typeInfo(field.type);
        const field_length = switch (field_info) {
            .Int => |int| if (int.signedness == .signed) @compileError("Fields must be unsigned ints") else int.bits,
            else => @compileError("Fields must be unsigned ints"),
        };
        const value = @field(message, field.name);
        inline for (0..field_length) |i| {
            const bit: u1 = @truncate(value >> i);
            const to_add: u8 = @as(u8, bit) << current_bit;
            buffer += to_add;
            current_bit = current_bit +% 1;
            if (current_bit == 0) {
                bytes[current_byte] = buffer;
                current_byte += 1;
                buffer = 0;
            }
        }
    }

    if (current_byte < size) {
        bytes[current_byte] = buffer;
    }

    return bytes;
}
