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
    const buffer_offset: u32 = 0;
    var bytes_offset: u32 = 0;

    inline for (t_info.Struct.fields) |field| {
        const value = @field(message, field.name);
        const field_size = @bitSizeOf(field.type);
        const loops = @ceil(@as(f64, field_size) / 8.0);
        for (0..loops) |i| {
            const padded_byte: u16 = @as(u8, @truncate(value >> @truncate(i * 8)));
            const to_add: u8 = @truncate(padded_byte << buffer_offset);
            buffer += to_add;
            bytes[bytes_offset] = buffer;
            bytes_offset += 1;
            buffer = 0;
        }
    }

    return bytes;
}

test "encode" {
    const std = @import("std");

    const MyStruct = packed struct {
        f1: u8,
        f2: u16,
    };

    const my = MyStruct{ .f1 = 0b11101111, .f2 = 0b1111111100000000 };

    std.debug.print("{b}", .{encode(my, 3)});
}
