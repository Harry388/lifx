pub const Header = struct {
    // Frame Header
    size: u16,
    protocol: u12,
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
