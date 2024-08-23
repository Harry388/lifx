const std = @import("std");
const root = @import("root.zig");

pub fn main() !void {
    const server = try root.Server.init("192.168.1.28", 56700);
    try server.bind();
    const msg = try server.listen(1024);
    std.debug.print("Received {} bytes: {s}", .{ msg.length, msg.buffer });
}
