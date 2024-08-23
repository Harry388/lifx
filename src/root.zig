const std = @import("std");
const expect = std.testing.expect;

pub const Socket = struct {
    address: std.net.Address,
    socket: std.posix.socket_t,

    pub fn init(ip: []const u8, port: u16) !Socket {
        const parsed_address = try std.net.Address.parseIp4(ip, port);
        const sock = try std.posix.socket(std.posix.AF.INET, std.posix.SOCK.DGRAM, 0);
        errdefer std.posix.close(sock);
        return Socket{ .address = parsed_address, .socket = sock };
    }

    pub fn bind(self: *const Socket) !void {
        try std.posix.bind(self.socket, &self.address.any, self.address.getOsSockLen());
    }

    pub fn listen(self: *const Socket) !void {
        var buffer: [1024]u8 = undefined;

        while (true) {
            const received_bytes = try std.posix.recvfrom(self.socket, buffer[0..], 0, null, null);
            std.debug.print("Received {d} bytes: {s}\n", .{ received_bytes, buffer[0..received_bytes] });
        }
    }
};

test "create a socket" {
    const socket = try Socket.init("127.0.0.1", 3000);
    try expect(@TypeOf(socket.socket) == std.posix.socket_t);
}
