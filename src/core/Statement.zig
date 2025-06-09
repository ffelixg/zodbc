const std = @import("std");
const testing = std.testing;

const err = @import("errors.zig");
const Handle = @import("Handle.zig");
const Environment = @import("Environment.zig");
const Connection = @import("Connection.zig");

const odbc = @import("odbc");
const attrs = odbc.attributes;
const rc = odbc.return_codes;
const sqlret = odbc.return_codes.sqlret;
const types = odbc.types;
const sql = odbc.sql;
const retconv1 = odbc.return_codes.retconv1;

const Self = @This();

handler: Handle,

pub fn init(con: Connection) !Self {
    const handler = try Handle.init(.STMT, con.handle());
    return .{ .handler = handler };
}

pub fn free(self: *const Self, option: enum(u16) { close = sql.c.SQL_CLOSE, drop = sql.c.SQL_DROP, unbind = sql.c.SQL_UNBIND, reset_params = sql.c.SQL_RESET_PARAMS }) !void {
    try retconv1(sql.c.SQLFreeStmt(self.handle(), @intFromEnum(option)));
}

pub fn closeCursor(self: *const Self) !void {
    try retconv1(sql.c.SQLCloseCursor(self.handle()));
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

pub fn colAttribute(self: Self, col_number: u16, comptime attr: attrs.ColAttribute) !@FieldType(attrs.ColAttributeValue, @tagName(attr)) {
    const T = @FieldType(attrs.ColAttributeValue, @tagName(attr));
    var num_attr: i64 = 0;
    try retconv1(sql.c.SQLColAttribute(
        self.handle(),
        col_number,
        @intFromEnum(attr),
        null,
        0,
        null,
        &num_attr,
    ));
    return switch (@typeInfo(T)) {
        .bool => switch (num_attr) {
            sql.c.SQL_TRUE => true,
            sql.c.SQL_FALSE => false,
            else => unreachable,
        },
        .int => num_attr,
        .@"enum" => @enumFromInt(num_attr),
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

/// Call getData until all data is read.
pub fn getDataVar(self: Self, col_number: u16, c_type: types.CDataType, data_ptr: *[]u8, ind: *i64, allocator: std.mem.Allocator) !void {
    const i_col: usize = col_number - 1;
    var start: usize = 0;
    var end: usize = 0;
    start = 0;

    const size_null_terminator: usize = switch (c_type) {
        .wchar => 2,
        .char => 1,
        .binary => 0,
        else => @panic("getDataVar only supports char, wchar and binary"),
    };
    std.debug.assert(data_ptr.*.len >= size_null_terminator);

    while (true) {
        if (self.getData(@intCast(i_col + 1), c_type, data_ptr.*[start..], ind)) {
            if (ind.* >= 0)
                ind.* += @intCast(start);
            std.debug.assert(ind.* >= 0 and ind.* <= data_ptr.*.len or ind.* == sql.c.SQL_NULL_DATA);
            break;
        } else |e| switch (e) {
            error.GetDataSuccessWithInfo => {},
            error.GetDataNoData => {
                if (ind.* >= 0)
                    ind.* += @intCast(start);
                std.debug.assert(ind.* >= 0 and ind.* <= data_ptr.*.len or ind.* == sql.c.SQL_NULL_DATA);
                break;
            },
            else => return e,
        }
        // SuccessWithInfo from here on
        if (ind.* < 0) {
            std.debug.assert(ind.* == sql.c.SQL_NO_TOTAL);
            end = data_ptr.*.len * 2;
        } else {
            end = start + @as(usize, @intCast(ind.*)) + size_null_terminator;
            std.debug.assert(end > data_ptr.*.len);
        }
        start = data_ptr.*.len - size_null_terminator;
        data_ptr.* = switch (c_type) {
            .wchar => @ptrCast(try allocator.realloc(
                @as([]u16, @alignCast(@ptrCast(data_ptr.*))),
                @divExact(end, 2),
            )),
            .char => try allocator.realloc(data_ptr.*, end),
            .binary => try allocator.realloc(data_ptr.*, end),
            else => @panic("getDataVar only supports char, wchar and binary"),
        };
    }
}

pub fn getData(self: Self, col_number: u16, c_type: types.CDataType, data: []u8, ind: *i64) !void {
    return switch (sql.c.SQLGetData(
        self.handle(),
        col_number,
        @intFromEnum(c_type),
        @ptrCast(data.ptr),
        @intCast(data.len),
        ind,
    )) {
        sql.c.SQL_SUCCESS => {},
        sql.c.SQL_SUCCESS_WITH_INFO => error.GetDataSuccessWithInfo,
        sql.c.SQL_NO_DATA => error.GetDataNoData,
        sql.c.SQL_STILL_EXECUTING => error.GetDataStillExecuting,
        sql.c.SQL_ERROR => error.GetDataError,
        sql.c.SQL_INVALID_HANDLE => error.GetDataInvalidHandle,
        else => unreachable,
    };
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

pub fn bindFileToCol(self: Self) !void {
    _ = self;
}

pub fn bindFileToParam(self: Self) !void {
    _ = self;
}

pub fn bindParameter(self: Self) !void {
    _ = self;
}

pub fn paramData(self: Self, T: type) !?*T {
    var ptr: ?*anyopaque = null;
    return switch (sql.c.SQLParamData(
        self.handle(),
        @ptrCast(&ptr),
    )) {
        sql.c.SQL_SUCCESS => null,
        sql.c.SQL_NEED_DATA => @alignCast(@ptrCast(ptr orelse unreachable)),
        sql.c.SQL_SUCCESS_WITH_INFO => error.ParamDataSuccessWithInfo,
        sql.c.SQL_NO_DATA => error.ParamDataNoData,
        sql.c.SQL_STILL_EXECUTING => error.ParamDataStillExecuting,
        sql.c.SQL_ERROR => error.ParamDataError,
        sql.c.SQL_INVALID_HANDLE => error.ParamDataInvalidHandle,
        sql.c.SQL_PARAM_DATA_AVAILABLE => error.ParamDataParamDataAvailable,
        else => unreachable,
    };
}

pub fn putData(self: Self, data: ?[]u8) !void {
    return switch (sql.c.SQLPutData(
        self.handle(),
        if (data) |d| @ptrCast(d.ptr) else null,
        if (data) |d| @intCast(d.len) else sql.c.SQL_NULL_DATA,
    )) {
        sql.c.SQL_SUCCESS => {},
        sql.c.SQL_SUCCESS_WITH_INFO => error.PutDataSuccessWithInfo,
        sql.c.SQL_STILL_EXECUTING => error.PutDataStillExecuting,
        sql.c.SQL_ERROR => error.PutDataError,
        sql.c.SQL_INVALID_HANDLE => error.PutDataInvalidHandle,
        else => unreachable,
    };
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
    const as_wide = try std.unicode.wtf8ToWtf16LeAllocZ(std.heap.c_allocator, stmt_str);
    defer std.heap.c_allocator.free(as_wide);
    return switch (sql.c.SQLExecDirectW(self.handle(), as_wide.ptr, @intCast(as_wide.len))) {
        sql.c.SQL_SUCCESS => {},
        sql.c.SQL_SUCCESS_WITH_INFO => error.ExecDirectSuccessWithInfo,
        sql.c.SQL_NEED_DATA => error.ExecDirectNeedData,
        sql.c.SQL_STILL_EXECUTING => error.ExecDirectStillExecuting,
        sql.c.SQL_ERROR => error.ExecDirectError,
        sql.c.SQL_NO_DATA => error.ExecDirectNoData,
        sql.c.SQL_INVALID_HANDLE => error.ExecDirectInvalidHandle,
        sql.c.SQL_PARAM_DATA_AVAILABLE => error.ExecDirectParamDataAvailable,
        else => unreachable,
    };
}

pub fn setStmtAttr(self: Self, comptime attr: attrs.StmtAttr, value: @FieldType(attrs.StmtAttrValue, @tagName(attr))) !void {
    const as_union = @unionInit(attrs.StmtAttrValue, @tagName(attr), value);
    const as_usize: usize = @bitCast(as_union);
    try retconv1(sql.c.SQLSetStmtAttr(
        self.handle(),
        @intFromEnum(attr),
        @ptrFromInt(as_usize),
        0,
    ));
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

pub fn moreResults(self: Self) !void {
    return switch (sql.c.SQLMoreResults(self.handle())) {
        sql.c.SQL_SUCCESS => {},
        sql.c.SQL_SUCCESS_WITH_INFO => error.MoreResultsSuccessWithInfo,
        sql.c.SQL_STILL_EXECUTING => error.MoreResultsStillExecuting,
        sql.c.SQL_NO_DATA => error.MoreResultsNoData,
        sql.c.SQL_ERROR => error.MoreResultsError,
        sql.c.SQL_INVALID_HANDLE => error.MoreResultsInvalidHandle,
        sql.c.SQL_PARAM_DATA_AVAILABLE => error.MoreResultsParamDataAvailable,
        else => unreachable,
    };
}

pub fn fetch(self: Self) !void {
    return switch (sql.c.SQLFetch(self.handle())) {
        sql.c.SQL_SUCCESS => {},
        sql.c.SQL_SUCCESS_WITH_INFO => error.FetchSuccessWithInfo,
        sql.c.SQL_STILL_EXECUTING => error.FetchStillExecuting,
        sql.c.SQL_NO_DATA => error.FetchNoData,
        sql.c.SQL_ERROR => error.FetchError,
        sql.c.SQL_INVALID_HANDLE => error.FetchInvalidHandle,
        else => unreachable,
    };
}

pub fn fetchScroll(
    self: Self,
    orientation: types.FetchOrientation,
    offset: i64,
) !void {
    return switch (sql.c.SQLFetchScroll(
        self.handle(),
        @intFromEnum(orientation),
        @intCast(offset),
    )) {
        sql.c.SQL_SUCCESS => {},
        sql.c.SQL_SUCCESS_WITH_INFO => error.FetchScrollSuccessWithInfo,
        sql.c.SQL_STILL_EXECUTING => error.FetchScrollStillExecuting,
        sql.c.SQL_NO_DATA => error.FetchScrollNoData,
        sql.c.SQL_ERROR => error.FetchScrollError,
        sql.c.SQL_INVALID_HANDLE => error.FetchScrollInvalidHandle,
        else => unreachable,
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
    const env = try Environment.init(.v3);
    defer env.deinit();
    const con = try Connection.init(env);
    defer con.deinit();

    try testing.expectError(
        err.AllocError.Error,
        Self.init(con),
    );
}
