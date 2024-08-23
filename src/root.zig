const std = @import("std");
const expect = std.testing.expect;

pub const Server = struct {
    address: std.net.Address,
    socket: std.posix.socket_t,

    pub fn init(ip: []const u8, port: u16) !Server {
        const parsed_address = try std.net.Address.parseIp4(ip, port);
        const sock = try std.posix.socket(std.posix.AF.INET, std.posix.SOCK.DGRAM, 0);
        errdefer std.posix.close(sock);
        return Server{ .address = parsed_address, .socket = sock };
    }

    pub fn bind(self: *const Server) !void {
        try std.posix.bind(self.socket, &self.address.any, self.address.getOsSockLen());
    }

    pub fn listen(self: *const Server, comptime size: usize) !struct {
        buffer: [size]u8,
        length: usize,
        src_address: std.posix.sockaddr,
        src_addrlen: std.posix.socklen_t,
    } {
        var buffer: [size]u8 = undefined;
        var src_address: std.posix.sockaddr = undefined;
        var src_addresslen: std.posix.socklen_t = @sizeOf(std.posix.sockaddr);
        const received_bytes = try std.posix.recvfrom(self.socket, buffer[0..], 0, &src_address, &src_addresslen);
        return .{ .buffer = buffer, .length = received_bytes, .src_address = src_address, .src_addrlen = src_addresslen };
    }

    pub fn send(
        self: *const Server,
        msg: []const u8,
        dest_addr: *const std.posix.sockaddr,
        addrlen: std.posix.socklen_t,
    ) !usize {
        return try std.posix.sendto(self.socket, msg, 0, dest_addr, addrlen);
    }
};

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

    pub fn listen(self: *const Client, comptime size: usize) !struct { buffer: [size]u8, length: usize } {
        var buffer: [size]u8 = undefined;
        const received_bytes = try std.posix.recv(self.socket, buffer[0..], 0);
        return .{ .buffer = buffer, .length = received_bytes };
    }

    pub fn send(self: *const Client, msg: []const u8) !usize {
        return try std.posix.send(self.socket, msg, 0);
    }
};
