const std = @import("std");
const Action = @import("action.zig").Action;

pub fn main() !void {
    var args = std.process.args();
    const cont = args.skip();
    if (!cont) unreachable;
    const arg_one = args.next() orelse {
        std.debug.print("IP not provided\n", .{});
        return;
    };
    const arg_two = args.next() orelse {
        std.debug.print("MAC Address not provided\n", .{});
        return;
    };
    const arg_three = args.next() orelse {
        std.debug.print("Action not provided\n", .{});
        return;
    };
    const mac = getMAC(arg_two) catch {
        std.debug.print("MAC Address invalid\n", .{});
        return;
    };
    const action: Action = Action.fromString(arg_three) orelse {
        std.debug.print("Unknown action\n", .{});
        return;
    };
    try action.enact(arg_one, mac);
}

fn getMAC(arg: []const u8) !u64 {
    var raw_mac = try std.fmt.parseInt(u64, arg, 16);
    raw_mac = raw_mac << 16;
    var mac_bytes = std.mem.toBytes(raw_mac);
    std.mem.reverse(u8, @ptrCast(&mac_bytes));
    return std.mem.bytesToValue(u64, &mac_bytes);
}
