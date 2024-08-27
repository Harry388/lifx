const encoder = @import("encoder.zig");

pub const Header = packed struct {
    // Frame Header
    size: u16,
    protocol: u12 = 1024,
    addressable: u1 = 1,
    tagged: u1, // (broadcast)
    origin: u2,
    source: u32,
    // Frame Address
    target: u64, // (set to all 0 for broadcast)
    r1: u48 = 0, // Reserved
    res_required: u1,
    ack_required: u1,
    r2: u6 = 0, // Reserved
    sequence: u8,
    // Protocol Header
    r3: u64 = 0, // Reserved
    type: u16,
    r4: u16 = 0, // Reserved
};

pub const Message = union(enum) {
    setPower: SetPower,
    getPower: GetPower,

    pub fn encode(self: *const Message, comptime messageSize: usize) [messageSize]u8 {
        var bytes: [messageSize]u8 = undefined;
        switch (self.*) {
            inline else => |case| {
                const T = @TypeOf(case);
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

                var current_byte: usize = 0;

                inline for (t_info.Struct.fields) |field| {
                    const value = @field(case, field.name);
                    const value_size = @ceil(@as(f64, @bitSizeOf(field.type)) / 8.0);
                    const encoded = encoder.encode(value, value_size);
                    for (encoded) |b| {
                        bytes[current_byte] = b;
                        current_byte += 1;
                    }
                }
            },
        }
        return bytes;
    }
};

pub const set_power_size = 38;

pub const SetPower = packed struct {
    header: Header,
    payload: packed struct {
        level: u16,
    },

    pub fn init(target: u64, level: u16) SetPower {
        return SetPower{
            .header = Header{
                .size = set_power_size,
                .tagged = 0,
                .origin = 0,
                .source = 2,
                .target = target,
                .res_required = 0,
                .ack_required = 1,
                .sequence = 1,
                .type = 21,
            },
            .payload = .{
                .level = level,
            },
        };
    }
};

pub const get_power_size = 36;

pub const GetPower = packed struct {
    header: Header,

    pub fn init(target: u64) GetPower {
        return GetPower{
            .header = Header{
                .size = get_power_size,
                .tagged = 0,
                .origin = 0,
                .source = 2,
                .target = target,
                .res_required = 1,
                .ack_required = 0,
                .sequence = 1,
                .type = 20,
            },
        };
    }
};
