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
const c = odbc.c;

const Self = @This();

handler: Handle,

pub fn init(con: Connection) !Self {
    const handler = try Handle.init(.STMT, con.handle());
    return .{ .handler = handler };
}

pub fn free(self: *const Self, option: enum(u16) { close = c.SQL_CLOSE, drop = c.SQL_DROP, unbind = c.SQL_UNBIND, reset_params = c.SQL_RESET_PARAMS }) !void {
    return switch (c.SQLFreeStmt(
        self.handle(),
        @intFromEnum(option),
    )) {
        c.SQL_SUCCESS => {},
        c.SQL_SUCCESS_WITH_INFO => error.FreeStmtSuccessWithInfo,
        c.SQL_ERROR => error.FreeStmtError,
        c.SQL_INVALID_HANDLE => error.FreeStmtInvalidHandle,
        else => unreachable,
    };
}

pub fn closeCursor(self: *const Self) !void {
    return switch (c.SQLCloseCursor(self.handle())) {
        c.SQL_SUCCESS => {},
        c.SQL_SUCCESS_WITH_INFO => error.CloseCursorSuccessWithInfo,
        c.SQL_ERROR => error.CloseCursorError,
        c.SQL_INVALID_HANDLE => error.CloseCursorInvalidHandle,
        else => unreachable,
    };
}

pub fn deinit(self: Self) !void {
    try self.handler.deinit();
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
    var odbc_buf: [1024]u16 = undefined;
    return switch (c.SQLColAttributeW(
        self.handle(),
        col_number,
        @intFromEnum(attr),
        &odbc_buf,
        @intCast(odbc_buf.len),
        &str_len,
        null,
    )) {
        c.SQL_SUCCESS => try std.unicode.wtf16LeToWtf8Alloc(allocator, odbc_buf[0..@intCast(str_len)]),
        c.SQL_SUCCESS_WITH_INFO => error.ColAttibuteSuccessWithInfo,
        c.SQL_ERROR => error.ColAttributeError,
        c.SQL_INVALID_HANDLE => error.ColAttributeInvalidHandle,
        else => unreachable,
    };
}

pub fn colAttributeStringZ(
    self: Self,
    col_number: u16,
    attr: attrs.ColAttributeString,
    allocator: std.mem.Allocator,
) ![:0]u8 {
    var str_len: i16 = 0;
    var odbc_buf: [1024]u16 = undefined;
    return switch (c.SQLColAttributeW(
        self.handle(),
        col_number,
        @intFromEnum(attr),
        &odbc_buf,
        @intCast(odbc_buf.len),
        &str_len,
        null,
    )) {
        c.SQL_SUCCESS => try std.unicode.wtf16LeToWtf8AllocZ(allocator, odbc_buf[0..@intCast(str_len)]),
        c.SQL_SUCCESS_WITH_INFO => error.ColAttibuteSuccessWithInfo,
        c.SQL_ERROR => error.ColAttributeError,
        c.SQL_INVALID_HANDLE => error.ColAttributeInvalidHandle,
        else => unreachable,
    };
}

pub fn colAttribute(self: Self, col_number: u16, comptime attr: attrs.ColAttribute) !@FieldType(attrs.ColAttributeValue, @tagName(attr)) {
    const T = @FieldType(attrs.ColAttributeValue, @tagName(attr));
    var num_attr: i64 = 0;
    return switch (c.SQLColAttributeW(
        self.handle(),
        col_number,
        @intFromEnum(attr),
        null,
        0,
        null,
        &num_attr,
    )) {
        c.SQL_SUCCESS => switch (@typeInfo(T)) {
            .bool => switch (num_attr) {
                c.SQL_TRUE => true,
                c.SQL_FALSE => false,
                else => unreachable,
            },
            .int => num_attr,
            .@"enum" => @enumFromInt(num_attr),
            else => unreachable,
        },
        c.SQL_SUCCESS_WITH_INFO => error.ColAttributeSuccessWithInfo,
        c.SQL_ERROR => error.ColAttributeError,
        c.SQL_INVALID_HANDLE => error.ColAttributeInvalidHandle,
        c.SQL_NO_DATA => error.ColAttributeNoData,
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
    const as_wide = try std.unicode.wtf8ToWtf16LeAllocZ(std.heap.c_allocator, stmt_str);
    defer std.heap.c_allocator.free(as_wide);
    return switch (c.SQLPrepareW(self.handle(), as_wide.ptr, @intCast(as_wide.len))) {
        c.SQL_SUCCESS => {},
        c.SQL_SUCCESS_WITH_INFO => error.PrepareSuccessWithInfo,
        c.SQL_ERROR => error.PrepareError,
        c.SQL_INVALID_HANDLE => error.PrepareInvalidHandle,
        else => unreachable,
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
            std.debug.assert(ind.* >= 0 and ind.* <= data_ptr.*.len or ind.* == c.SQL_NULL_DATA);
            break;
        } else |e| switch (e) {
            error.GetDataSuccessWithInfo => {},
            error.GetDataNoData => {
                if (ind.* >= 0)
                    ind.* += @intCast(start);
                std.debug.assert(ind.* >= 0 and ind.* <= data_ptr.*.len or ind.* == c.SQL_NULL_DATA);
                break;
            },
            else => return e,
        }
        // SuccessWithInfo from here on
        if (ind.* < 0) {
            std.debug.assert(ind.* == c.SQL_NO_TOTAL);
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
    return switch (c.SQLGetData(
        self.handle(),
        col_number,
        @intFromEnum(c_type),
        @ptrCast(data.ptr),
        @intCast(data.len),
        ind,
    )) {
        c.SQL_SUCCESS => {},
        c.SQL_SUCCESS_WITH_INFO => error.GetDataSuccessWithInfo,
        c.SQL_NO_DATA => error.GetDataNoData,
        c.SQL_STILL_EXECUTING => error.GetDataStillExecuting,
        c.SQL_ERROR => error.GetDataError,
        c.SQL_INVALID_HANDLE => error.GetDataInvalidHandle,
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
    return switch (c.SQLParamData(
        self.handle(),
        @ptrCast(&ptr),
    )) {
        c.SQL_SUCCESS => null,
        c.SQL_NEED_DATA => @alignCast(@ptrCast(ptr orelse unreachable)),
        c.SQL_SUCCESS_WITH_INFO => error.ParamDataSuccessWithInfo,
        c.SQL_NO_DATA => error.ParamDataNoData,
        c.SQL_STILL_EXECUTING => error.ParamDataStillExecuting,
        c.SQL_ERROR => error.ParamDataError,
        c.SQL_INVALID_HANDLE => error.ParamDataInvalidHandle,
        c.SQL_PARAM_DATA_AVAILABLE => error.ParamDataParamDataAvailable,
        else => unreachable,
    };
}

pub fn putData(self: Self, data: ?[]u8) !void {
    return switch (c.SQLPutData(
        self.handle(),
        if (data) |d| @ptrCast(d.ptr) else null,
        if (data) |d| @intCast(d.len) else c.SQL_NULL_DATA,
    )) {
        c.SQL_SUCCESS => {},
        c.SQL_SUCCESS_WITH_INFO => error.PutDataSuccessWithInfo,
        c.SQL_STILL_EXECUTING => error.PutDataStillExecuting,
        c.SQL_ERROR => error.PutDataError,
        c.SQL_INVALID_HANDLE => error.PutDataInvalidHandle,
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
    return switch (c.SQLExecute(self.handle())) {
        c.SQL_SUCCESS => {},
        c.SQL_SUCCESS_WITH_INFO => error.ExecuteSuccessWithInfo,
        c.SQL_NEED_DATA => error.ExecuteNeedData,
        c.SQL_STILL_EXECUTING => error.ExecuteStillExecuting,
        c.SQL_ERROR => error.ExecuteError,
        c.SQL_NO_DATA => error.ExecuteNoData,
        c.SQL_INVALID_HANDLE => error.ExecuteInvalidHandle,
        c.SQL_PARAM_DATA_AVAILABLE => error.ExecuteParamDataAvailable,
        else => unreachable,
    };
}

pub fn execDirect(self: Self, stmt_str: []const u8) !void {
    const as_wide = try std.unicode.wtf8ToWtf16LeAllocZ(std.heap.c_allocator, stmt_str);
    defer std.heap.c_allocator.free(as_wide);
    return switch (c.SQLExecDirectW(self.handle(), as_wide.ptr, @intCast(as_wide.len))) {
        c.SQL_SUCCESS => {},
        c.SQL_SUCCESS_WITH_INFO => error.ExecDirectSuccessWithInfo,
        c.SQL_NEED_DATA => error.ExecDirectNeedData,
        c.SQL_STILL_EXECUTING => error.ExecDirectStillExecuting,
        c.SQL_ERROR => error.ExecDirectError,
        c.SQL_NO_DATA => error.ExecDirectNoData,
        c.SQL_INVALID_HANDLE => error.ExecDirectInvalidHandle,
        c.SQL_PARAM_DATA_AVAILABLE => error.ExecDirectParamDataAvailable,
        else => unreachable,
    };
}

pub fn setStmtAttr(
    self: Self,
    comptime attr: attrs.StmtAttr,
    value: @FieldType(attrs.StmtAttrValue, @tagName(attr)),
) !void {
    return switch (c.SQLSetStmtAttrW(
        self.handle(),
        @intFromEnum(attr),
        @ptrFromInt(@import("utils.zig").toUsize(value)),
        0,
    )) {
        c.SQL_SUCCESS => {},
        c.SQL_SUCCESS_WITH_INFO => error.SetStmtAttrSuccessWithInfo,
        c.SQL_ERROR => error.SetStmtAttrError,
        c.SQL_INVALID_HANDLE => error.SetStmtAttrInvalidHandle,
        else => unreachable,
    };
}

pub fn getStmtAttr(
    self: Self,
    comptime attr: attrs.StmtAttr,
) !@FieldType(attrs.StmtAttrValue, @tagName(attr)) {
    var value_ptr: ?*anyopaque = null;
    return switch (c.SQLGetStmtAttrW(
        self.handle(),
        @intFromEnum(attr),
        @ptrCast(&value_ptr),
        0,
        null,
    )) {
        c.SQL_SUCCESS => @import("utils.zig").fromUsize(
            @FieldType(attrs.StmtAttrValue, @tagName(attr)),
            @intFromPtr(value_ptr),
        ),
        c.SQL_SUCCESS_WITH_INFO => error.GetStmtAttrSuccessWithInfo,
        c.SQL_ERROR => error.GetStmtAttrError,
        c.SQL_INVALID_HANDLE => error.GetStmtAttrInvalidHandle,
        else => unreachable,
    };
}

pub fn moreResults(self: Self) !void {
    return switch (c.SQLMoreResults(self.handle())) {
        c.SQL_SUCCESS => {},
        c.SQL_SUCCESS_WITH_INFO => error.MoreResultsSuccessWithInfo,
        c.SQL_STILL_EXECUTING => error.MoreResultsStillExecuting,
        c.SQL_NO_DATA => error.MoreResultsNoData,
        c.SQL_ERROR => error.MoreResultsError,
        c.SQL_INVALID_HANDLE => error.MoreResultsInvalidHandle,
        c.SQL_PARAM_DATA_AVAILABLE => error.MoreResultsParamDataAvailable,
        else => unreachable,
    };
}

pub fn fetch(self: Self) !void {
    return switch (c.SQLFetch(self.handle())) {
        c.SQL_SUCCESS => {},
        c.SQL_SUCCESS_WITH_INFO => error.FetchSuccessWithInfo,
        c.SQL_STILL_EXECUTING => error.FetchStillExecuting,
        c.SQL_NO_DATA => error.FetchNoData,
        c.SQL_ERROR => error.FetchError,
        c.SQL_INVALID_HANDLE => error.FetchInvalidHandle,
        else => unreachable,
    };
}

pub fn fetchScroll(
    self: Self,
    orientation: types.FetchOrientation,
    offset: i64,
) !void {
    return switch (c.SQLFetchScroll(
        self.handle(),
        @intFromEnum(orientation),
        @intCast(offset),
    )) {
        c.SQL_SUCCESS => {},
        c.SQL_SUCCESS_WITH_INFO => error.FetchScrollSuccessWithInfo,
        c.SQL_STILL_EXECUTING => error.FetchScrollStillExecuting,
        c.SQL_NO_DATA => error.FetchScrollNoData,
        c.SQL_ERROR => error.FetchScrollError,
        c.SQL_INVALID_HANDLE => error.FetchScrollInvalidHandle,
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
    defer env.deinit() catch unreachable;
    const con = try Connection.init(env);
    defer con.deinit() catch unreachable;

    try testing.expectError(
        err.AllocError.Error,
        Self.init(con),
    );
}
