const std = @import("std");
const odbc = @import("odbc");
const types = odbc.types;
const sql = odbc.sql;
const c = odbc.c;

const Self = @This();

handle_type: types.HandleType,
handle: ?*anyopaque,

pub fn init(handle_type: types.HandleType, input_handle: ?*anyopaque) !Self {
    var handler: Self = .{
        .handle_type = handle_type,
        .handle = null,
    };

    return switch (sql.SQLAllocHandle(
        handle_type,
        input_handle,
        &handler.handle,
    )) {
        .ERR => AllocError.Error,
        .INVALID_HANDLE => AllocError.InvalidHandle,
        else => handler,
    };
}

pub fn deinit(self: Self) !void {
    return switch (c.SQLFreeHandle(@intFromEnum(self.handle_type), self.handle)) {
        c.SQL_SUCCESS => {},
        c.SQL_ERROR => error.FreeHandleError,
        c.SQL_INVALID_HANDLE => error.FreeHandleInvalidHandle,
        else => unreachable,
    };
}

pub fn getLastError(self: Self) sql.LastError {
    return sql.getLastError(self.handle_type, self.handle);
}

pub const AllocError = error{
    Error,
    InvalidHandle,
};
