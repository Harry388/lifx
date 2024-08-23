const std = @import("std");
const root = @import("root.zig");

pub fn main() !void {
    const client = try root.Client.init("127.0.0.1", 56700);
    try client.connect();
    const msg_size = try client.send("Hello!");
    std.debug.print("Sent {}\n", .{msg_size});
}
