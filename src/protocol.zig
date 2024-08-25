const message = @import("message.zig");

pub const Header = packed struct {
    // Frame Header
    size: u16,
    protocol: u12 = 1024,
    addressable: u1,
    tagged: u1,
    origin: u2,
    source: u32,
    // Frame Address
    target: u64,
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
                .addressable = 1,
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
                .addressable = 1,
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
