const std = @import("std");
const message = @import("message.zig");
const Action = @import("action.zig").Action;

pub fn main() !void {
    var args = std.process.args();
    const cont = args.skip();
    if (!cont) unreachable;
    const arg_one = args.next() orelse {
        std.debug.print("Identifier not provided\n", .{});
        return;
    };
    const arg_two = args.next() orelse {
        std.debug.print("Action not provided\n", .{});
        return;
    };
    const ip = genIP(arg_one) orelse {
        std.debug.print("Identifier must be 3 characters\n", .{});
        return;
    };
    const action: Action = Action.fromString(arg_two) orelse {
        std.debug.print("Unknown action\n", .{});
        return;
    };
    try action.enact(&ip);
}

fn genIP(end: []const u8) ?[13]u8 {
    if (end.len != 3) return null;
    var ip: [13]u8 = undefined;
    const start = "192.168.1.";
    var i: usize = 0;
    for (start) |b| {
        ip[i] = b;
        i += 1;
    }
    for (end) |b| {
        ip[i] = b;
        i += 1;
    }
    return ip;
}
