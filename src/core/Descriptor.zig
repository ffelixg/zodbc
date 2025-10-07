const std = @import("std");

const Handle = @import("Handle.zig");
const Statement = @import("Statement.zig");

const odbc = @import("odbc");
const attrs = odbc.attributes;
const types = odbc.types;
const sql = odbc.sql;
const c = odbc.c;

const DescriptorKind = enum { imp_row_desc, app_row_desc, imp_param_desc, app_param_desc };

fn FieldValueUnion(comptime descriptor_kind: DescriptorKind) type {
    return union {
        alloc_type: attrs.AllocType,
        array_size: u64,
        array_status_ptr: switch (descriptor_kind) {
            .imp_row_desc => ?[*]attrs.RowStatus,
            .app_row_desc => ?[*]attrs.RowOperation,
            .imp_param_desc => ?[*]attrs.ParamStatus,
            .app_param_desc => ?[*]attrs.ParamOperation,
        },
        bind_offset_ptr: ?*i64,
        bind_type: i32,
        count: i16,
        rows_processed_ptr: ?*u64,
        auto_unique_value: bool,
        case_sensitive: bool,
        concise_type: switch (descriptor_kind) {
            .app_param_desc, .app_row_desc => types.CDataType,
            .imp_param_desc, .imp_row_desc => types.SQLDataType,
        },
        data_ptr: ?[*]u8,
        datetime_interval_code: attrs.DateTimeIntervalCode,
        datetime_interval_precision: i32,
        display_size: i64,
        fixed_prec_scale: bool,
        indicator_ptr: ?[*]i64,
        length: u64,
        nullable: attrs.Nullable,
        num_prec_radix: attrs.NumPrecRadix,
        octet_length: i64,
        octet_length_ptr: ?[*]i64,
        parameter_type: attrs.ParameterType,
        precision: i16,
        rowver: bool,
        scale: i16,
        searchable: attrs.Searchable,
        type: switch (descriptor_kind) {
            .app_param_desc, .app_row_desc => types.CDataType,
            .imp_param_desc, .imp_row_desc => types.SQLDataType,
        },
        unnamed: attrs.Unnamed,
        unsigned: bool,
        updatable: attrs.Updatable,
    };
}

fn FieldType(comptime attr: anytype, comptime descriptor_kind: DescriptorKind) type {
    const T = @FieldType(FieldValueUnion(descriptor_kind), @tagName(attr));
    switch (@typeInfo(T)) {
        .pointer => |info| {
            if (info.child == u8) {
                @compileError("Strings are not implemented yet");
            }
        },
        else => {},
    }
    return T;
}

fn getFieldGeneric(
    handle: ?*anyopaque,
    col_number: u15,
    comptime attr: anytype,
    comptime descriptor_kind: DescriptorKind,
) !FieldType(attr, descriptor_kind) {
    var value_ptr: ?*anyopaque = null;
    switch (c.SQLGetDescFieldW(
        handle,
        col_number,
        @intFromEnum(attr),
        @ptrCast(&value_ptr),
        0,
        null,
    )) {
        c.SQL_SUCCESS => {},
        c.SQL_SUCCESS_WITH_INFO => return error.GetDescFieldSuccessWithInfo,
        c.SQL_ERROR => return error.GetDescFieldError,
        c.SQL_NO_DATA => return error.GetDescFieldNoData,
        c.SQL_INVALID_HANDLE => return error.GetDescFieldInvalidHandle,
        else => unreachable,
    }
    return @import("utils.zig").fromUsize(FieldType(attr, descriptor_kind), @intFromPtr(value_ptr));
}

fn setFieldGeneric(
    handle: ?*anyopaque,
    col_number: u15,
    comptime attr: anytype,
    comptime descriptor_kind: DescriptorKind,
    value: FieldType(attr, descriptor_kind),
) !void {
    return switch (c.SQLSetDescFieldW(
        handle,
        col_number,
        @intFromEnum(attr),
        @ptrFromInt(@import("utils.zig").toUsize(value)),
        0,
    )) {
        c.SQL_SUCCESS => {},
        c.SQL_SUCCESS_WITH_INFO => error.SetDescFieldSuccessWithInfo,
        c.SQL_ERROR => error.SetDescFieldError,
        c.SQL_INVALID_HANDLE => error.SetDescFieldInvalidHandle,
        else => unreachable,
    };
}

fn getFieldGenericString(
    handle: ?*anyopaque,
    col_number: u15,
    comptime attr: anytype,
    allocator: std.mem.Allocator,
) ![:0]u8 {
    var buffer: [1024]u16 = undefined;
    var len: isize = 0;
    switch (c.SQLGetDescFieldW(
        handle,
        col_number,
        @intFromEnum(attr),
        @ptrCast(&buffer),
        buffer.len,
        @ptrCast(&len),
    )) {
        c.SQL_SUCCESS => {},
        c.SQL_SUCCESS_WITH_INFO => return error.GetDescFieldSuccessWithInfo,
        c.SQL_ERROR => return error.GetDescFieldError,
        c.SQL_NO_DATA => return error.GetDescFieldNoData,
        c.SQL_INVALID_HANDLE => return error.GetDescFieldInvalidHandle,
        else => unreachable,
    }
    return try std.unicode.wtf16LeToWtf8AllocZ(
        allocator,
        buffer[0..@intCast(@divExact(len, 2))],
    );
}

fn setFieldGenericString(
    handle: ?*anyopaque,
    col_number: u15,
    comptime attr: anytype,
    value: []const u8,
) !void {
    const value_wide = try std.unicode.wtf8ToWtf16LeAllocZ(std.heap.c_allocator, value);
    defer std.heap.c_allocator.free(value_wide);
    return switch (c.SQLSetDescFieldW(
        handle,
        col_number,
        @intFromEnum(attr),
        @ptrCast(value_wide.ptr),
        @intCast(value_wide.len * 2),
    )) {
        c.SQL_SUCCESS => {},
        c.SQL_SUCCESS_WITH_INFO => error.SetDescFieldSuccessWithInfo,
        c.SQL_ERROR => error.SetDescFieldError,
        c.SQL_INVALID_HANDLE => error.SetDescFieldInvalidHandle,
        else => unreachable,
    };
}

const ReadFieldsAppRowDesc = enum(u15) {
    array_size = c.SQL_DESC_ARRAY_SIZE,
    array_status_ptr = c.SQL_DESC_ARRAY_STATUS_PTR,
    bind_offset_ptr = c.SQL_DESC_BIND_OFFSET_PTR,
    bind_type = c.SQL_DESC_BIND_TYPE,
    count = c.SQL_DESC_COUNT,
    concise_type = c.SQL_DESC_CONCISE_TYPE,
    data_ptr = c.SQL_DESC_DATA_PTR,
    datetime_interval_code = c.SQL_DESC_DATETIME_INTERVAL_CODE,
    datetime_interval_precision = c.SQL_DESC_DATETIME_INTERVAL_PRECISION,
    indicator_ptr = c.SQL_DESC_INDICATOR_PTR,
    length = c.SQL_DESC_LENGTH,
    num_prec_radix = c.SQL_DESC_NUM_PREC_RADIX,
    octet_length = c.SQL_DESC_OCTET_LENGTH,
    octet_length_ptr = c.SQL_DESC_OCTET_LENGTH_PTR,
    precision = c.SQL_DESC_PRECISION,
    scale = c.SQL_DESC_SCALE,
    type = c.SQL_DESC_TYPE,
    // read only fields
    alloc_type = c.SQL_DESC_ALLOC_TYPE,
};

const ReadFieldsAppParamDesc = enum(u15) {
    array_size = c.SQL_DESC_ARRAY_SIZE,
    array_status_ptr = c.SQL_DESC_ARRAY_STATUS_PTR,
    bind_offset_ptr = c.SQL_DESC_BIND_OFFSET_PTR,
    bind_type = c.SQL_DESC_BIND_TYPE,
    count = c.SQL_DESC_COUNT,
    concise_type = c.SQL_DESC_CONCISE_TYPE,
    data_ptr = c.SQL_DESC_DATA_PTR,
    datetime_interval_code = c.SQL_DESC_DATETIME_INTERVAL_CODE,
    datetime_interval_precision = c.SQL_DESC_DATETIME_INTERVAL_PRECISION,
    indicator_ptr = c.SQL_DESC_INDICATOR_PTR,
    length = c.SQL_DESC_LENGTH,
    num_prec_radix = c.SQL_DESC_NUM_PREC_RADIX,
    octet_length = c.SQL_DESC_OCTET_LENGTH,
    octet_length_ptr = c.SQL_DESC_OCTET_LENGTH_PTR,
    precision = c.SQL_DESC_PRECISION,
    scale = c.SQL_DESC_SCALE,
    type = c.SQL_DESC_TYPE,
    // read only fields
    alloc_type = c.SQL_DESC_ALLOC_TYPE,
};

const ReadFieldsImpRowDesc = enum(u15) {
    array_status_ptr = c.SQL_DESC_ARRAY_STATUS_PTR,
    rows_processed_ptr = c.SQL_DESC_ROWS_PROCESSED_PTR,
    // read only fields
    alloc_type = c.SQL_DESC_ALLOC_TYPE,
    count = c.SQL_DESC_COUNT,
    auto_unique_value = c.SQL_DESC_AUTO_UNIQUE_VALUE,
    case_sensitive = c.SQL_DESC_CASE_SENSITIVE,
    concise_type = c.SQL_DESC_CONCISE_TYPE,
    datetime_interval_code = c.SQL_DESC_DATETIME_INTERVAL_CODE,
    datetime_interval_precision = c.SQL_DESC_DATETIME_INTERVAL_PRECISION,
    display_size = c.SQL_DESC_DISPLAY_SIZE,
    fixed_prec_scale = c.SQL_DESC_FIXED_PREC_SCALE,
    length = c.SQL_DESC_LENGTH,
    nullable = c.SQL_DESC_NULLABLE,
    num_prec_radix = c.SQL_DESC_NUM_PREC_RADIX,
    octet_length = c.SQL_DESC_OCTET_LENGTH,
    precision = c.SQL_DESC_PRECISION,
    rowver = c.SQL_DESC_ROWVER,
    scale = c.SQL_DESC_SCALE,
    searchable = c.SQL_DESC_SEARCHABLE,
    type = c.SQL_DESC_TYPE,
    unnamed = c.SQL_DESC_UNNAMED,
    unsigned = c.SQL_DESC_UNSIGNED,
    updatable = c.SQL_DESC_UPDATABLE,
};

const ReadFieldsImpRowDescString = enum(u15) {
    base_column_name = c.SQL_DESC_BASE_COLUMN_NAME,
    base_table_name = c.SQL_DESC_BASE_TABLE_NAME,
    catalog_name = c.SQL_DESC_CATALOG_NAME,
    label = c.SQL_DESC_LABEL,
    literal_prefix = c.SQL_DESC_LITERAL_PREFIX,
    literal_suffix = c.SQL_DESC_LITERAL_SUFFIX,
    schema_name = c.SQL_DESC_SCHEMA_NAME,
    table_name = c.SQL_DESC_TABLE_NAME,
    type_name = c.SQL_DESC_TYPE_NAME,
    local_type_name = c.SQL_DESC_LOCAL_TYPE_NAME,
    name = c.SQL_DESC_NAME,
};

const ReadFieldsImpParamDesc = enum(u15) {
    array_status_ptr = c.SQL_DESC_ARRAY_STATUS_PTR,
    count = c.SQL_DESC_COUNT,
    rows_processed_ptr = c.SQL_DESC_ROWS_PROCESSED_PTR,
    concise_type = c.SQL_DESC_CONCISE_TYPE,
    datetime_interval_code = c.SQL_DESC_DATETIME_INTERVAL_CODE,
    datetime_interval_precision = c.SQL_DESC_DATETIME_INTERVAL_PRECISION,
    length = c.SQL_DESC_LENGTH,
    num_prec_radix = c.SQL_DESC_NUM_PREC_RADIX,
    octet_length = c.SQL_DESC_OCTET_LENGTH,
    parameter_type = c.SQL_DESC_PARAMETER_TYPE,
    precision = c.SQL_DESC_PRECISION,
    scale = c.SQL_DESC_SCALE,
    type = c.SQL_DESC_TYPE,
    unnamed = c.SQL_DESC_UNNAMED,
    // read only fields
    alloc_type = c.SQL_DESC_ALLOC_TYPE,
    case_sensitive = c.SQL_DESC_CASE_SENSITIVE,
    fixed_prec_scale = c.SQL_DESC_FIXED_PREC_SCALE,
    nullable = c.SQL_DESC_NULLABLE,
    rowver = c.SQL_DESC_ROWVER,
    type_name = c.SQL_DESC_TYPE_NAME,
    unsigned = c.SQL_DESC_UNSIGNED,
};

const ReadFieldsImpParamDescString = enum(u15) {
    local_type_name = c.SQL_DESC_LOCAL_TYPE_NAME,
    name = c.SQL_DESC_NAME,
    ss_type_name = c.SQL_CA_SS_TYPE_NAME,
    ss_schema_name = c.SQL_CA_SS_SCHEMA_NAME,
};

const WriteFieldsAppRowDesc = enum(u15) {
    array_size = c.SQL_DESC_ARRAY_SIZE,
    array_status_ptr = c.SQL_DESC_ARRAY_STATUS_PTR,
    bind_offset_ptr = c.SQL_DESC_BIND_OFFSET_PTR,
    bind_type = c.SQL_DESC_BIND_TYPE,
    count = c.SQL_DESC_COUNT,
    concise_type = c.SQL_DESC_CONCISE_TYPE,
    data_ptr = c.SQL_DESC_DATA_PTR,
    datetime_interval_code = c.SQL_DESC_DATETIME_INTERVAL_CODE,
    datetime_interval_precision = c.SQL_DESC_DATETIME_INTERVAL_PRECISION,
    indicator_ptr = c.SQL_DESC_INDICATOR_PTR,
    length = c.SQL_DESC_LENGTH,
    num_prec_radix = c.SQL_DESC_NUM_PREC_RADIX,
    octet_length = c.SQL_DESC_OCTET_LENGTH,
    octet_length_ptr = c.SQL_DESC_OCTET_LENGTH_PTR,
    precision = c.SQL_DESC_PRECISION,
    scale = c.SQL_DESC_SCALE,
    type = c.SQL_DESC_TYPE,
};

const WriteFieldsAppParamDesc = enum(u15) {
    array_size = c.SQL_DESC_ARRAY_SIZE,
    array_status_ptr = c.SQL_DESC_ARRAY_STATUS_PTR,
    bind_offset_ptr = c.SQL_DESC_BIND_OFFSET_PTR,
    bind_type = c.SQL_DESC_BIND_TYPE,
    count = c.SQL_DESC_COUNT,
    concise_type = c.SQL_DESC_CONCISE_TYPE,
    data_ptr = c.SQL_DESC_DATA_PTR,
    datetime_interval_code = c.SQL_DESC_DATETIME_INTERVAL_CODE,
    datetime_interval_precision = c.SQL_DESC_DATETIME_INTERVAL_PRECISION,
    indicator_ptr = c.SQL_DESC_INDICATOR_PTR,
    length = c.SQL_DESC_LENGTH,
    num_prec_radix = c.SQL_DESC_NUM_PREC_RADIX,
    octet_length = c.SQL_DESC_OCTET_LENGTH,
    octet_length_ptr = c.SQL_DESC_OCTET_LENGTH_PTR,
    precision = c.SQL_DESC_PRECISION,
    scale = c.SQL_DESC_SCALE,
    type = c.SQL_DESC_TYPE,
};

const WriteFieldsImpRowDesc = enum(u15) {
    array_status_ptr = c.SQL_DESC_ARRAY_STATUS_PTR,
    rows_processed_ptr = c.SQL_DESC_ROWS_PROCESSED_PTR,
};

const WriteFieldsImpParamDesc = enum(u15) {
    array_status_ptr = c.SQL_DESC_ARRAY_STATUS_PTR,
    count = c.SQL_DESC_COUNT,
    rows_processed_ptr = c.SQL_DESC_ROWS_PROCESSED_PTR,
    concise_type = c.SQL_DESC_CONCISE_TYPE,
    datetime_interval_code = c.SQL_DESC_DATETIME_INTERVAL_CODE,
    datetime_interval_precision = c.SQL_DESC_DATETIME_INTERVAL_PRECISION,
    length = c.SQL_DESC_LENGTH,
    num_prec_radix = c.SQL_DESC_NUM_PREC_RADIX,
    octet_length = c.SQL_DESC_OCTET_LENGTH,
    parameter_type = c.SQL_DESC_PARAMETER_TYPE,
    precision = c.SQL_DESC_PRECISION,
    scale = c.SQL_DESC_SCALE,
    type = c.SQL_DESC_TYPE,
    unnamed = c.SQL_DESC_UNNAMED,
};

const WriteFieldsImpParamDescString = enum(u15) {
    name = c.SQL_DESC_NAME,
    ss_type_name = c.SQL_CA_SS_TYPE_NAME,
    ss_schema_name = c.SQL_CA_SS_SCHEMA_NAME,
};

pub const AppRowDesc = struct {
    handler: Handle,

    const Self = @This();

    pub fn fromStatement(stmt: Statement) !Self {
        const handler: Handle = .{
            .handle = try stmt.getStmtAttr(.app_row_desc),
            .handle_type = .DESC,
        };
        return .{ .handler = handler };
    }

    pub fn handle(self: Self) ?*anyopaque {
        return self.handler.handle;
    }

    pub fn getLastError(self: Self) sql.LastError {
        return self.handler.getLastError();
    }

    pub fn setField(
        self: Self,
        col_number: u15,
        comptime field: WriteFieldsAppRowDesc,
        value: FieldType(field, .app_row_desc),
    ) !void {
        try setFieldGeneric(
            self.handle(),
            col_number,
            field,
            .app_row_desc,
            value,
        );
    }

    pub fn getField(
        self: Self,
        col_number: u15,
        comptime attr: ReadFieldsAppRowDesc,
    ) !FieldType(attr, .app_row_desc) {
        return try getFieldGeneric(
            self.handle(),
            col_number,
            attr,
            .app_row_desc,
        );
    }
};

pub const ImpRowDesc = struct {
    handler: Handle,

    const Self = @This();

    pub fn fromStatement(stmt: Statement) !Self {
        const handler: Handle = .{
            .handle = try stmt.getStmtAttr(.imp_row_desc),
            .handle_type = .DESC,
        };
        return .{ .handler = handler };
    }

    pub fn handle(self: Self) ?*anyopaque {
        return self.handler.handle;
    }

    pub fn getLastError(self: Self) sql.LastError {
        return self.handler.getLastError();
    }

    pub fn setField(
        self: Self,
        col_number: u15,
        comptime field: WriteFieldsImpRowDesc,
        value: FieldType(field, .imp_row_desc),
    ) !void {
        try setFieldGeneric(
            self.handle(),
            col_number,
            field,
            .imp_row_desc,
            value,
        );
    }

    pub fn getField(
        self: Self,
        col_number: u15,
        comptime attr: ReadFieldsImpRowDesc,
    ) !FieldType(attr, .imp_row_desc) {
        return try getFieldGeneric(
            self.handle(),
            col_number,
            attr,
            .imp_row_desc,
        );
    }

    pub fn getFieldString(
        self: Self,
        col_number: u15,
        comptime attr: ReadFieldsImpRowDescString,
        allocator: std.mem.Allocator,
    ) ![:0]u8 {
        return try getFieldGenericString(
            self.handle(),
            col_number,
            attr,
            allocator,
        );
    }
};

pub const AppParamDesc = struct {
    handler: Handle,

    const Self = @This();

    pub fn fromStatement(stmt: Statement) !Self {
        const handler: Handle = .{
            .handle = try stmt.getStmtAttr(.app_param_desc),
            .handle_type = .DESC,
        };
        return .{ .handler = handler };
    }

    pub fn handle(self: Self) ?*anyopaque {
        return self.handler.handle;
    }

    pub fn getLastError(self: Self) sql.LastError {
        return self.handler.getLastError();
    }

    pub fn setField(
        self: Self,
        col_number: u15,
        comptime field: WriteFieldsAppParamDesc,
        value: FieldType(field, .app_param_desc),
    ) !void {
        try setFieldGeneric(
            self.handle(),
            col_number,
            field,
            .app_param_desc,
            value,
        );
    }

    pub fn getField(
        self: Self,
        col_number: u15,
        comptime attr: ReadFieldsAppParamDesc,
    ) !FieldType(attr, .app_param_desc) {
        return try getFieldGeneric(
            self.handle(),
            col_number,
            attr,
            .app_param_desc,
        );
    }
};

pub const ImpParamDesc = struct {
    handler: Handle,

    const Self = @This();

    pub fn fromStatement(stmt: Statement) !Self {
        const handler: Handle = .{
            .handle = try stmt.getStmtAttr(.imp_param_desc),
            .handle_type = .DESC,
        };
        return .{ .handler = handler };
    }

    pub fn handle(self: Self) ?*anyopaque {
        return self.handler.handle;
    }

    pub fn getLastError(self: Self) sql.LastError {
        return self.handler.getLastError();
    }

    pub fn setField(
        self: Self,
        col_number: u15,
        comptime field: WriteFieldsImpParamDesc,
        value: FieldType(field, .imp_param_desc),
    ) !void {
        try setFieldGeneric(
            self.handle(),
            col_number,
            field,
            .imp_param_desc,
            value,
        );
    }

    pub fn setFieldString(
        self: Self,
        col_number: u15,
        comptime field: WriteFieldsImpParamDescString,
        value: []const u8,
    ) !void {
        try setFieldGenericString(
            self.handle(),
            col_number,
            field,
            value,
        );
    }

    pub fn getField(
        self: Self,
        col_number: u15,
        comptime attr: ReadFieldsImpParamDesc,
    ) !FieldType(attr, .imp_param_desc) {
        return try getFieldGeneric(
            self.handle(),
            col_number,
            attr,
            .imp_param_desc,
        );
    }

    pub fn getFieldString(
        self: Self,
        col_number: u15,
        comptime attr: ReadFieldsImpParamDescString,
        allocator: std.mem.Allocator,
    ) ![:0]u8 {
        return try getFieldGenericString(
            self.handle(),
            col_number,
            attr,
            allocator,
        );
    }
};
