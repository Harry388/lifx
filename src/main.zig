const std = @import("std");
const root = @import("root.zig");

pub fn main() !void {
    const socket = try root.Socket.init("192.168.1.28", 56700);
    try socket.bind();
    try socket.listen();
}
