const std = @import("std");
const testing = std.testing;

const Handle = @import("Handle.zig");
const Statement = @import("Statement.zig");

const odbc = @import("odbc");
const attrs = odbc.attributes;
const types = odbc.types;
const sql = odbc.sql;
const sqlret = odbc.return_codes.sqlret;
const retconv1 = odbc.return_codes.retconv1;

const Self = @This();

handler: Handle,
descriptor_kind: attrs.StmtAttrHandle,

pub fn init(stmt: Statement, descriptor_kind: attrs.StmtAttrHandle) !Self {
    // const handler = try Handle.init(.DESC, stmt.handle());
    const handler: Handle = .{ .handle = try stmt.getStmtAttrHandle(descriptor_kind), .handle_type = .DESC };
    return .{ .handler = handler, .descriptor_kind = descriptor_kind };
}

pub fn deinit(self: Self) void {
    self.handler.deinit();
}

pub fn handle(self: Self) ?*anyopaque {
    return self.handler.handle;
}

pub fn getLastError(self: Self) sql.LastError {
    return self.handler.getLastError();
}

pub fn setField(self: Self, col_number: i16, field: attrs.DescFieldI16, value: i16) !void {
    const value_as_ptr: *anyopaque = blk: {
        @setRuntimeSafety(false);
        const as_usize: usize = @intCast(value);
        std.debug.print("as_usize: {}\n", .{as_usize});
        break :blk @ptrFromInt(as_usize);
    };
    return _setField(self, col_number, field, value_as_ptr, @sizeOf(i16));
}

fn _setField(self: Self, col_number: i16, field: anytype, value_ptr: *anyopaque, value_size: i32) !void {
    return switch (sql.c.SQLSetDescField(
        self.handle(),
        col_number,
        @intFromEnum(field),
        value_ptr,
        value_size,
    )) {
        sqlret.success => {},
        sqlret.success_with_info => error.Info,
        sqlret.err => error.Error,
        sqlret.invalid_handle => error.InvalidHandle,
        else => unreachable,
    };
}

pub fn getDataPtr(self: Self, col_number: i16) !*anyopaque {
    var value_ptr: ?*anyopaque = null;
    try retconv1(sql.c.SQLGetDescField(
        self.handle(),
        col_number,
        @intFromEnum(attrs.DescFieldMisc.data_ptr),
        @ptrCast(&value_ptr),
        sql.c.SQL_IS_POINTER,
        null,
    ));
    return value_ptr orelse unreachable;
}

pub fn setDataPtr(self: Self, col_number: i16, data_ptr: *anyopaque) !void {
    try retconv1(sql.c.SQLSetDescField(
        self.handle(),
        col_number,
        @intFromEnum(attrs.DescFieldMisc.data_ptr),
        data_ptr,
        sql.c.SQL_IS_POINTER,
    ));
}
