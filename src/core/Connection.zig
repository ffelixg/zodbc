const std = @import("std");

const Environment = @import("Environment.zig");
const Handle = @import("Handle.zig");

const odbc = @import("odbc");
const info = odbc.info;
const attrs = odbc.attributes;
const sql = odbc.sql;
const c = odbc.c;

const InfoType = info.InfoType;
const InfoTypeValue = info.InfoTypeValue;
const Attribute = attrs.ConnectionAttribute;
const AttributeValue = attrs.ConnectionAttributeValue;

const Self = @This();

handler: Handle,

pub fn init(env: Environment) !Self {
    const handler = try Handle.init(.DBC, env.handle());
    return .{ .handler = handler };
}

pub fn deinit(self: *const Self) void {
    self.handler.deinit();
}

pub fn handle(self: *const Self) ?*anyopaque {
    return self.handler.handle;
}

pub fn getLastError(self: *const Self) sql.LastError {
    return self.handler.getLastError();
}

pub fn getInfo(
    self: Self,
    allocator: std.mem.Allocator,
    info_type: InfoType,
    odbc_buf: []u8,
) !InfoTypeValue {
    var str_len: i16 = undefined;

    return switch (sql.SQLGetInfo(
        self.handle(),
        info_type,
        odbc_buf.ptr,
        @intCast(odbc_buf.len),
        &str_len,
    )) {
        .SUCCESS, .SUCCESS_WITH_INFO => InfoTypeValue.init(allocator, info_type, odbc_buf, str_len),
        .ERR => {
            const lastError = self.getLastError();
            std.debug.print("lastError: {}\n", .{lastError});
            return GetInfoError.Error;
        },
        .INVALID_HANDLE => GetInfoError.InvalidHandle,
    };
}

pub fn getConnectAttr(
    self: Self,
    allocator: std.mem.Allocator,
    attr: Attribute,
    odbc_buf: []u8,
) !AttributeValue {
    var str_len: i32 = undefined;

    return switch (sql.SQLGetConnectAttr(
        self.handle(),
        attr,
        odbc_buf.ptr,
        @intCast(odbc_buf.len),
        &str_len,
    )) {
        .SUCCESS, .SUCCESS_WITH_INFO => AttributeValue.init(allocator, attr, odbc_buf, str_len),
        .ERR => {
            const lastError = self.getLastError();
            std.debug.print("lastError: {}\n", .{lastError});
            return GetConnectAttrError.Error;
        },
        .INVALID_HANDLE => GetConnectAttrError.InvalidHandle,
        .NO_DATA => GetConnectAttrError.NoData,
    };
}

pub fn setConnectAttr(
    self: Self,
    attr_value: AttributeValue,
) !void {
    return switch (sql.SQLSetConnectAttr(
        self.handle(),
        attr_value.getActiveTag(),
        attr_value.getValue(),
        attr_value.getStrLen(),
    )) {
        .SUCCESS => {},
        .ERR => {
            const lastError = self.getLastError();
            std.debug.print("lastError: {}\n", .{lastError});
            return SetConnectAttrError.Error;
        },
        .INVALID_HANDLE => SetConnectAttrError.InvalidHandle,
    };
}

pub fn connectWithString(self: *const Self, constr: []const u8) !void {
    const constr_16 = try std.unicode.wtf8ToWtf16LeAllocZ(std.heap.smp_allocator, constr);
    defer std.heap.smp_allocator.free(constr_16);
    return switch (c.SQLDriverConnectW(
        self.handle(),
        null,
        @ptrCast(@constCast(constr_16)),
        @intCast(constr_16.len),
        null,
        0,
        null,
        c.SQL_DRIVER_NOPROMPT,
    )) {
        c.SQL_SUCCESS => {},
        c.SQL_SUCCESS_WITH_INFO => {},
        c.SQL_ERROR => error.DriverConnectError,
        c.SQL_INVALID_HANDLE => return error.DriverConnectInvalidHandle,
        c.SQL_NO_DATA => return error.DriverConnectNoData,
        else => unreachable,
    };
}

pub fn disconnect(self: *const Self) !void {
    return switch (c.SQLDisconnect(self.handle())) {
        c.SQL_SUCCESS => {},
        c.SQL_SUCCESS_WITH_INFO => error.DisconnectSuccessWithInfo,
        c.SQL_ERROR => error.DisconnectError,
        c.SQL_INVALID_HANDLE => return error.DisconnectInvalidHandle,
        else => unreachable,
    };
}

pub const DriverConnectError = error{
    Error,
    InvalidHandle,
    NoDataFound,
};

pub const GetInfoError = error{
    Error,
    InvalidHandle,
};

pub const GetConnectAttrError = error{
    Error,
    InvalidHandle,
    NoData,
};

pub const SetConnectAttrError = error{
    Error,
    InvalidHandle,
};
