const std = @import("std");
const socket = @import("socket.zig");
const message = @import("message.zig");
const protocol = @import("protocol.zig");

const Action = enum {
    on,
    off,

    fn fromString(action: []const u8) ?Action {
        return if (stringEquals(action, "on"))
            .on
        else if (stringEquals(action, "off"))
            .off
        else
            null;
    }
};

pub fn main() !void {
    var args = std.process.args();
    const cont = args.skip();
    if (!cont) unreachable;
    const action_arg = args.next() orelse {
        std.debug.print("No action provided\n", .{});
        return;
    };
    const action = Action.fromString(action_arg) orelse {
        std.debug.print("Unknown action\n", .{});
        return;
    };
    try toggleLight(action);
}

fn toggleLight(action: Action) !void {
    const msg = protocol.SetPower.init(0x453430d573d0, switch (action) {
        .on => 65535,
        .off => 0,
    });

    const encoded = message.multiEncode(msg, protocol.set_power_size);

    const client = try socket.Client.init("192.168.1.252", 56700);
    try client.connect();
    _ = try client.send(&encoded);
}

fn stringEquals(one: []const u8, two: []const u8) bool {
    if (one.len != two.len) return false;
    for (one, two) |one_c, two_c| {
        if (one_c != two_c) return false;
    }
    return true;
}
