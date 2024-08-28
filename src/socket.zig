const std = @import("std");

pub const Client = struct {
    address: std.net.Address,
    socket: std.posix.socket_t,

    pub fn init(ip: []const u8, port: u16) !Client {
        const parsed_address = try std.net.Address.parseIp4(ip, port);
        const sock = try std.posix.socket(std.posix.AF.INET, std.posix.SOCK.DGRAM, 0);
        errdefer std.posix.close(sock);
        return Client{ .address = parsed_address, .socket = sock };
    }

    pub fn connect(self: *const Client) !void {
        try std.posix.connect(self.socket, &self.address.any, self.address.getOsSockLen());
    }

    pub fn setBroadcast(self: *const Client, enable: bool) !void {
        const val: u32 = if (enable) 1 else 0;
        const val_bytes = std.mem.asBytes(&val);
        try std.posix.setsockopt(self.socket, std.posix.SOL.SOCKET, std.posix.SO.BROADCAST, val_bytes);
    }

    pub fn listen(self: *const Client, comptime size: usize) !struct { buffer: [size]u8, length: usize } {
        var buffer: [size]u8 = undefined;
        const received_bytes = try std.posix.recv(self.socket, buffer[0..], 0);
        return .{ .buffer = buffer, .length = received_bytes };
    }

    pub fn send(self: *const Client, msg: []const u8) !usize {
        return try std.posix.send(self.socket, msg, 0);
    }
};
