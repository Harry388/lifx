const socket = @import("socket.zig");
const protocol = @import("protocol.zig");
const message = @import("message.zig");
const util = @import("util.zig");

pub const Action = enum {
    on,
    off,

    pub fn fromString(action: []const u8) ?Action {
        return if (util.stringEquals(action, "on"))
            .on
        else if (util.stringEquals(action, "off"))
            .off
        else
            null;
    }

    pub fn enact(self: *const Action, ip: []const u8) !void {
        const msg = protocol.SetPower.init(0x453430d573d0, switch (self.*) {
            .on => 65535,
            .off => 0,
        });

        const encoded = message.multiEncode(msg, protocol.set_power_size);

        const client = try socket.Client.init(ip, 56700);
        try client.connect();
        _ = try client.send(&encoded);
    }
};
