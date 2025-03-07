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

fn _intToPtr(value: anytype) *anyopaque {
    @setRuntimeSafety(false);
    const as_usize: usize = @intCast(value);
    return @ptrFromInt(as_usize);
}

fn _PtrToInt(T: type, ptr: ?*anyopaque) T {
    @setRuntimeSafety(false);
    const as_usize: usize = @intFromPtr(ptr);
    return @intCast(as_usize);
}

pub fn setI16Field(self: Self, col_number: i16, field: attrs.DescFieldI16, value: i16) !void {
    try retconv1(sql.c.SQLSetDescField(
        self.handle(),
        col_number,
        @intFromEnum(field),
        _intToPtr(value),
        sql.c.SQL_IS_SMALLINT,
    ));
}

pub fn setU64Field(self: Self, col_number: i16, attr: attrs.DescFieldU64, value: u64) !void {
    try retconv1(sql.c.SQLSetDescField(
        self.handle(),
        col_number,
        @intFromEnum(attr),
        _intToPtr(value),
        sql.c.SQL_IS_UINTEGER,
    ));
}

pub fn setI64Field(self: Self, col_number: i16, attr: attrs.DescFieldI64, value: i64) !void {
    try retconv1(sql.c.SQLSetDescField(
        self.handle(),
        col_number,
        @intFromEnum(attr),
        _intToPtr(value),
        sql.c.SQL_IS_INTEGER,
    ));
}

pub fn getU64Field(self: Self, col_number: i16, attr: attrs.DescFieldU64) !u64 {
    var value_ptr: ?*anyopaque = null;
    try retconv1(sql.c.SQLGetDescField(
        self.handle(),
        col_number,
        @intFromEnum(attr),
        @ptrCast(&value_ptr),
        sql.c.SQL_IS_UINTEGER,
        null,
    ));
    return _PtrToInt(u64, value_ptr);
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

pub fn getIndicatorPtr(self: Self, col_number: i16) ![*]i64 {
    var indicator_ptr: ?[*]i64 = null;
    try retconv1(sql.c.SQLGetDescField(
        self.handle(),
        col_number,
        @intFromEnum(attrs.DescFieldMisc.indicator_ptr),
        @ptrCast(&indicator_ptr),
        sql.c.SQL_IS_POINTER,
        null,
    ));
    return indicator_ptr orelse unreachable;
}

pub fn setIndicatorPtr(self: Self, col_number: i16, indicator_ptr: [*]i64) !void {
    try retconv1(sql.c.SQLSetDescField(
        self.handle(),
        col_number,
        @intFromEnum(attrs.DescFieldMisc.indicator_ptr),
        @ptrCast(indicator_ptr),
        sql.c.SQL_IS_POINTER,
    ));
    try retconv1(sql.c.SQLSetDescField(
        self.handle(),
        col_number,
        @intFromEnum(attrs.DescFieldMisc.octet_length_ptr),
        @ptrCast(indicator_ptr),
        sql.c.SQL_IS_POINTER,
    ));
}

pub fn setField(self: Self, col_number: i16, comptime field: attrs.DescField, value: @FieldType(attrs.DescFieldValue, @tagName(field))) !void {
    const as_union = @unionInit(attrs.DescFieldValue, @tagName(field), value);
    const as_usize: usize = @bitCast(as_union);
    try retconv1(sql.c.SQLSetDescField(
        self.handle(),
        col_number,
        @intFromEnum(field),
        @ptrFromInt(as_usize),
        0,
    ));
}

pub fn getField(self: Self, col_number: i16, comptime attr: attrs.DescField) !@FieldType(attrs.DescFieldValue, @tagName(attr)) {
    var value_ptr: ?*anyopaque = null;
    try retconv1(sql.c.SQLGetDescField(
        self.handle(),
        col_number,
        @intFromEnum(attr),
        @ptrCast(&value_ptr),
        0,
        null,
    ));
    const T = @FieldType(attrs.DescFieldValue, @tagName(attr));
    return switch (@typeInfo(T)) {
        .bool => switch (@intFromPtr(value_ptr)) {
            sql.c.SQL_TRUE => true,
            sql.c.SQL_FALSE => false,
            else => unreachable,
        },
        .int => _PtrToInt(T, value_ptr),
        .@"enum" => @enumFromInt(value_ptr),
        .optional, .pointer => @alignCast(@ptrCast(value_ptr)),
        else => unreachable,
    };
}
