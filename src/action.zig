const std = @import("std");
const socket = @import("socket.zig");
const protocol = @import("protocol.zig");
const util = @import("util.zig");

pub const Action = enum {
    on,
    off,
    toggle,

    pub fn fromString(action: []const u8) ?Action {
        return if (util.stringEquals(action, "on"))
            .on
        else if (util.stringEquals(action, "off"))
            .off
        else if (util.stringEquals(action, "toggle"))
            .toggle
        else
            null;
    }

    pub fn enact(self: *const Action, ip: []const u8, target: u64) !void {
        const client = try socket.Client.init(ip, 56700);
        try client.connect();
        switch (self.*) {
            .on, .off => {
                const msg = protocol.Message{ .setPower = protocol.SetPower.init(target, switch (self.*) {
                    .on => 65535,
                    .off => 0,
                    else => unreachable,
                }) };

                const encoded = msg.encode(protocol.set_power_size);

                _ = try client.send(&encoded);
            },
            .toggle => {
                const msg = protocol.Message{ .getPower = protocol.GetPower.init(target) };
                const encoded = msg.encode(protocol.get_power_size);

                _ = try client.send(&encoded);

                const resp = try client.listen(38);
                if (resp.length == 38) {
                    const toggle_msg = protocol.Message{ .setPower = protocol.SetPower.init(target, if (resp.buffer[37] > 0) 0 else 65535) };
                    const toggle_encoded = toggle_msg.encode(protocol.set_power_size);

                    _ = try client.send(&toggle_encoded);
                }
            },
        }
    }
};
