const std = @import("std");
const testing = std.testing;

const err = @import("errors.zig");
const Handle = @import("Handle.zig");
const Environment = @import("Environment.zig");
const Connection = @import("Connection.zig");

const odbc = @import("odbc");
const attrs = odbc.attributes;
const rc = odbc.return_codes;
const types = odbc.types;
const sql = odbc.sql;

const Self = @This();

handler: Handle,

const sqlret = struct {
    const success = sql.c.SQL_SUCCESS;
    const success_with_info = sql.c.SQL_SUCCESS_WITH_INFO;
    const err = sql.c.SQL_ERROR;
    const invalid_handle = sql.c.SQL_INVALID_HANDLE;
    const still_executing = sql.c.SQL_STILL_EXECUTING;
    const need_data = sql.c.SQL_NEED_DATA;
    const no_data_found = sql.c.SQL_NO_DATA_FOUND;
};

pub fn init(con: Connection) !Self {
    const handler = try Handle.init(.STMT, con.handle());
    return .{ .handler = handler };
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

pub fn disconnect(self: Self) !void {
    _ = self;
}

pub fn dataSources(self: Self) !void {
    _ = self;
}

pub fn tables(self: Self) !void {
    _ = self;
}

pub fn tablePrivileges(self: Self) !void {
    _ = self;
}

pub fn specialColumns(self: Self) !void {
    _ = self;
}

pub fn columns(
    self: Self,
    catalog_name: []const u8,
    schema_name: []const u8,
    table_name: []const u8,
    column_name: []const u8,
) !void {
    return switch (sql.SQLColumns(
        self.handle(),
        catalog_name,
        schema_name,
        table_name,
        column_name,
    )) {
        .SUCCESS, .SUCCESS_WITH_INFO => {},
        .ERR => ColumnsError.Error,
        .INVALID_HANDLE => ColumnsError.InvalidHandle,
    };
}

pub fn columnPrivileges(self: Self) !void {
    _ = self;
}

pub fn colAttributeString(
    self: Self,
    col_number: u16,
    attr: attrs.ColAttributeString,
    allocator: std.mem.Allocator,
) ![]u8 {
    var str_len: i16 = 0;
    var odbc_buf: [1024]u8 = undefined;
    return switch (sql.c.SQLColAttribute(
        self.handle(),
        col_number,
        @intFromEnum(attr),
        &odbc_buf,
        @intCast(odbc_buf.len),
        &str_len,
        null,
    )) {
        sqlret.success, sqlret.success_with_info => try allocator.dupe(u8, odbc_buf[0..@intCast(str_len)]),
        sqlret.err => error.Error,
        sqlret.invalid_handle => error.InvalidHandle,
        else => unreachable,
    };
}

pub fn colAttributeEnum(
    self: Self,
    col_number: u16,
    attr: attrs.ColAttributeEnum,
) !attrs.ColAttributeEnumValue {
    var num_val: i64 = undefined;
    return switch (sql.c.SQLColAttribute(
        self.handle(),
        col_number,
        @intFromEnum(attr),
        null,
        0,
        null,
        &num_val,
    )) {
        sqlret.success, sqlret.success_with_info => attrs.ColAttributeEnumValue.init(attr, num_val),
        sqlret.err => error.Error,
        sqlret.invalid_handle => error.InvalidHandle,
        else => unreachable,
    };
}

pub fn colAttributeInt(
    self: Self,
    col_number: u16,
    attr: attrs.ColAttributeInt,
) !i64 {
    var num_val: i64 = undefined;
    return switch (sql.c.SQLColAttribute(
        self.handle(),
        col_number,
        @intFromEnum(attr),
        null,
        0,
        null,
        &num_val,
    )) {
        sqlret.success, sqlret.success_with_info => num_val,
        sqlret.err => error.Error,
        sqlret.invalid_handle => error.InvalidHandle,
        else => unreachable,
    };
}

pub fn colAttributeBool(
    self: Self,
    col_number: u16,
    attr: attrs.ColAttributeBool,
) !bool {
    var num_val: i64 = undefined;
    return switch (sql.c.SQLColAttribute(
        self.handle(),
        col_number,
        @intFromEnum(attr),
        null,
        0,
        null,
        &num_val,
    )) {
        sqlret.success, sqlret.success_with_info => switch (num_val) {
            sql.c.SQL_TRUE => true,
            sql.c.SQL_FALSE => false,
            else => unreachable,
        },
        sqlret.err => error.Error,
        sqlret.invalid_handle => error.InvalidHandle,
        else => unreachable,
    };
}

pub fn colAttributes(self: Self) !void {
    _ = self;
}

pub fn primaryKeys(self: Self) !void {
    _ = self;
}

pub fn foreignKeys(self: Self) !void {
    _ = self;
}

pub fn statistics(self: Self) !void {
    _ = self;
}

pub fn procedures(self: Self) !void {
    _ = self;
}

pub fn procedureColumns(self: Self) !void {
    _ = self;
}

pub fn getFunctions(self: Self) !void {
    _ = self;
}

pub fn cancel(self: Self) !void {
    _ = self;
}

pub fn endTran(self: Self) !void {
    _ = self;
}

pub fn describeParam(self: Self) !void {
    _ = self;
}

pub fn prepare(self: Self, stmt_str: []const u8) !void {
    return switch (sql.SQLPrepare(self.handle(), stmt_str)) {
        .SUCCESS, .SUCCESS_WITH_INFO => {},
        .ERR => PrepareError.Error,
        .INVALID_HANDLE => PrepareError.InvalidHandle,
    };
}

pub fn numResultCols(self: Self) !usize {
    var column_count: usize = 0;
    return switch (sql.SQLNumResultCols(self.handle(), &column_count)) {
        .SUCCESS => column_count,
        .ERR => NumResultColsError.Error,
        .INVALID_HANDLE => NumResultColsError.InvalidHandle,
        .STILL_EXECUTING => NumResultColsError.StillExecuting,
    };
}

pub fn describeCol(
    self: Self,
    col_number: usize,
    col_desc: *types.ColDescription,
) !void {
    switch (sql.SQLDescribeCol(
        self.handle(),
        col_number,
        col_desc,
    )) {
        .SUCCESS => {},
        .ERR => {
            const lastError = self.getLastError();
            std.debug.print("lastError: {}\n", .{lastError});
            return DescribeColError.Error;
        },
        .INVALID_HANDLE => return DescribeColError.InvalidHandle,
        // .STILL_EXECUTING => return DescribeColError.StillExecuting,
    }
}

pub fn bindCol(
    self: Self,
    col_number: c_ushort,
    col: *types.Column,
) !void {
    return switch (sql.SQLBindCol(
        self.handle(),
        col_number,
        col,
    )) {
        .SUCCESS => {},
        .ERR => {
            const lastError = self.getLastError();
            std.debug.print("lastError: {}\n", .{lastError});
            return BindColError.Error;
        },
        .INVALID_HANDLE => BindColError.InvalidHandle,
    };
}

pub fn bindCol2(
    self: Self,
    col_number: u16,
    c_type: types.CDataType,
    buffer: *anyopaque,
    buffer_length: i64,
    indicator: [*]i64,
) !void {
    return switch (sql.c.SQLBindCol(
        self.handle(),
        col_number,
        @intFromEnum(c_type),
        buffer,
        buffer_length,
        indicator,
    )) {
        sqlret.success => {},
        sqlret.success_with_info => error.Info,
        sqlret.err => error.Error,
        sqlret.invalid_handle => error.InvalidHandle,
        else => unreachable,
    };
}

pub fn bindFileToCol(self: Self) !void {
    _ = self;
}

pub fn bindFileToParam(self: Self) !void {
    _ = self;
}

pub fn bindParameter(self: Self) !void {
    _ = self;
}

pub fn getCursorName(self: Self) void {
    _ = self;
}

pub fn setCursorName(self: Self) !void {
    _ = self;
}

pub fn setPos(self: Self) !void {
    _ = self;
}

pub fn execute(self: Self) !void {
    return switch (sql.SQLExecute(self.handle())) {
        .SUCCESS, .SUCCESS_WITH_INFO => {},
        .ERR => ExecuteError.Error,
        .INVALID_HANDLE => ExecuteError.InvalidHandle,
        .NEED_DATA => ExecuteError.NeedData,
        .NO_DATA_FOUND => ExecuteError.NoDataFound,
    };
}

pub fn execDirect(self: Self, stmt_str: []const u8) !void {
    return switch (sql.SQLExecDirect(self.handle(), stmt_str)) {
        .SUCCESS, .SUCCESS_WITH_INFO => {},
        .ERR => ExecDirectError.Error,
        .INVALID_HANDLE => ExecDirectError.InvalidHandle,
        .NEED_DATA => ExecDirectError.NeedData,
        .NO_DATA_FOUND => ExecDirectError.NoDataFound,
    };
}

pub fn setStmtAttr(self: Self) !void {
    _ = self;
}

pub fn setStmtAttrHandle(self: Self, ptr_kind: attrs.StmtAttrHandle, ptr: *anyopaque) !void {
    return self._setStmtAttrPtr(ptr_kind, ptr);
}
pub fn setStmtAttrU64Ptr(self: Self, ptr_kind: attrs.StmtAttrU64Ptr, ptr: [*]u64) !void {
    return self._setStmtAttrPtr(ptr_kind, ptr);
}
pub fn setStmtAttrU16Ptr(self: Self, ptr_kind: attrs.StmtAttrU16Ptr, ptr: [*]u16) !void {
    return self._setStmtAttrPtr(ptr_kind, ptr);
}

fn _setStmtAttrPtr(self: Self, ptr_kind: anytype, ptr: anytype) !void {
    return switch (sql.c.SQLSetStmtAttr(
        self.handle(),
        @intFromEnum(ptr_kind),
        ptr,
        sql.c.SQL_IS_POINTER,
    )) {
        sqlret.success => {},
        sqlret.success_with_info => error.Info,
        sqlret.err => error.Error,
        sqlret.invalid_handle => error.InvalidHandle,
        else => unreachable,
    };
}

pub fn getStmtAttrHandle(self: Self, ptr_kind: attrs.StmtAttrHandle) !*anyopaque {
    return self._getStmtAttrPtr(ptr_kind, *anyopaque);
}
pub fn getStmtAttrU64Ptr(self: Self, ptr_kind: attrs.StmtAttrU64Ptr) ![*]u64 {
    return self._getStmtAttrPtr(ptr_kind, [*]u64);
}
pub fn getStmtAttrU16Ptr(self: Self, ptr_kind: attrs.StmtAttrU16Ptr) ![*]u16 {
    return self._getStmtAttrPtr(ptr_kind, [*]u16);
}

fn _getStmtAttrPtr(self: Self, ptr_kind: anytype, T: type) !T {
    // var ptr: ?T = null;
    var ptr: ?*anyopaque = null;
    return switch (sql.c.SQLGetStmtAttr(
        self.handle(),
        @intFromEnum(ptr_kind),
        @ptrCast(&ptr),
        // &ptr,
        // @sizeOf(T),
        0,
        sql.c.SQL_IS_POINTER,
    )) {
        // sqlret.success => ptr orelse unreachable,
        sqlret.success => @alignCast(@ptrCast(ptr orelse unreachable)),
        sqlret.success_with_info => error.Info,
        sqlret.err => error.Error,
        sqlret.invalid_handle => error.InvalidHandle,
        else => unreachable,
    };
}

pub fn getStmtAttr(self: Self) !void {
    _ = self;
}

pub fn setDescField(self: Self, col_number: i16, descriptor_kind: attrs.StmtAttrHandle, field: attrs.DescFieldI16, value: i16) !void {
    const descriptor_handle = try self.getStmtAttrHandle(descriptor_kind);
    const value_as_ptr: *anyopaque = blk: {
        @setRuntimeSafety(false);
        const as_usize: usize = @intCast(value);
        break :blk @ptrFromInt(as_usize);
    };
    return switch (sql.c.SQLSetDescField(
        descriptor_handle,
        col_number,
        @intFromEnum(field),
        // @ptrFromInt(@as(isize, value)),
        value_as_ptr,
        0,
    )) {
        sqlret.success => {},
        sqlret.success_with_info => error.Info,
        sqlret.err => error.Error,
        sqlret.invalid_handle => error.InvalidHandle,
        else => unreachable,
    };
}

pub fn moreResults(self: Self) !void {
    _ = self;
}

pub fn fetch(self: Self) !void {
    return switch (sql.SQLFetch(self.handle())) {
        .SUCCESS, .SUCCESS_WITH_INFO => {},
        .ERR => FetchError.Error,
        .INVALID_HANDLE => FetchError.InvalidHandle,
        .NO_DATA_FOUND => FetchError.NoDataFound,
    };
}

pub fn fetchScroll(
    self: Self,
    orientation: types.FetchOrientation,
    offset: i64,
) !void {
    return switch (sql.SQLFetchScroll(
        self.handle(),
        orientation,
        offset,
    )) {
        .SUCCESS, .SUCCESS_WITH_INFO => {},
        .ERR => FetchScrollError.Error,
        .INVALID_HANDLE => FetchScrollError.InvalidHandle,
        // .NEED_DATA => FetchScrollError.NeedData,
        // .NO_DATA_FOUND => FetchScrollError.NoDataFound,
    };
}

pub fn describeColumns(self: Self) !void {
    _ = self;
}

pub const ColumnsError = error{
    Error,
    InvalidHandle,
};

pub const PrepareError = error{
    Error,
    InvalidHandle,
};

pub const NumResultColsError = error{
    Error,
    InvalidHandle,
    StillExecuting,
};

pub const DescribeColError = error{
    Error,
    InvalidHandle,
    // StillExecuting,
};

pub const BindColError = error{
    Error,
    InvalidHandle,
};

pub const ExecuteError = error{
    Error,
    InvalidHandle,
    NeedData,
    NoDataFound,
};

pub const ExecDirectError = error{
    Error,
    InvalidHandle,
    NeedData,
    NoDataFound,
};

pub const FetchError = error{
    Error,
    InvalidHandle,
    NoDataFound,
};

pub const FetchScrollError = error{
    Error,
    InvalidHandle,
    // NeedData,
    // NoDataFound,
};

test ".init/1 returns an error when called without an established connection" {
    const env = try Environment.init(.V3);
    defer env.deinit();
    const con = try Connection.init(env);
    defer con.deinit();

    try testing.expectError(
        err.AllocError.Error,
        Self.init(con),
    );
}
