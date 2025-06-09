const std = @import("std");

const Handle = @import("Handle.zig");
const Statement = @import("Statement.zig");

const odbc = @import("odbc");
const attrs = odbc.attributes;
const types = odbc.types;
const sql = odbc.sql;
const c = odbc.c;

fn FieldValueUnion(comptime descriptor_kind: attrs.StmtAttrHandle) type {
    return extern union {
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
        base_column_name: ?[*:0]u8,
        base_table_name: ?[*:0]u8,
        case_sensitive: bool,
        catalog_name: ?[*:0]u8,
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
        label: ?[*:0]u8,
        length: u64,
        literal_prefix: ?[*:0]u8,
        literal_suffix: ?[*:0]u8,
        local_type_name: ?[*:0]u8,
        name: ?[*:0]u8,
        nullable: attrs.Nullable,
        num_prec_radix: attrs.NumPrecRadix,
        octet_length: i64,
        octet_length_ptr: ?[*]i64,
        parameter_type: attrs.ParameterType,
        precision: i16,
        rowver: bool,
        scale: i16,
        schema_name: ?[*:0]u8,
        searchable: attrs.Searchable,
        table_name: ?[*:0]u8,
        type: switch (descriptor_kind) {
            .app_param_desc, .app_row_desc => types.CDataType,
            .imp_param_desc, .imp_row_desc => types.SQLDataType,
        },
        type_name: ?[*:0]u8,
        unnamed: attrs.Unnamed,
        unsigned: bool,
        updatable: attrs.Updatable,
    };
}

fn FieldType(comptime attr: anytype, comptime descriptor_kind: attrs.StmtAttrHandle) type {
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

inline fn fromUsize(T: type, val: usize) T {
    switch (@typeInfo(T)) {
        .pointer => return @ptrFromInt(val),
        .optional => |info| {
            comptime std.debug.assert(@typeInfo(info.child) == .pointer);
            return @ptrFromInt(val);
        },
        .int => |info| {
            switch (info.signedness) {
                .signed => {
                    const sval: isize = @bitCast(val);
                    return @intCast(sval);
                },
                .unsigned => return @intCast(val),
            }
        },
        .@"enum" => |info| {
            switch (@typeInfo(info.tag_type).int.signedness) {
                .signed => {
                    const sval: isize = @bitCast(val);
                    return @enumFromInt(sval);
                },
                .unsigned => return @enumFromInt(val),
            }
        },
        .bool => return switch (val) {
            0 => false,
            1 => true,
            else => unreachable,
        },
        else => @compileError(@typeName(T)),
    }
}

inline fn toUsize(val: anytype) usize {
    switch (@typeInfo(@TypeOf(val))) {
        .pointer => return @intFromPtr(val),
        .optional => |info| {
            comptime std.debug.assert(@typeInfo(info.child) == .pointer);
            return @intFromPtr(val);
        },
        .int => |info| {
            switch (info.signedness) {
                .signed => return @bitCast(@as(isize, val)),
                .unsigned => return @as(usize, val),
            }
        },
        .@"enum" => {
            const as_int = @intFromEnum(val);
            switch (@typeInfo(@TypeOf(as_int)).int.signedness) {
                .signed => return @bitCast(@as(isize, as_int)),
                .unsigned => return @as(usize, as_int),
            }
        },
        .bool => @intFromBool(val),
        else => @compileError(@typeName(@TypeOf(val))),
    }
}

fn getFieldGeneric(
    handle: ?*anyopaque,
    col_number: i16,
    comptime attr: anytype,
    comptime descriptor_kind: attrs.StmtAttrHandle,
) !FieldType(attr, descriptor_kind) {
    var value_ptr: ?*anyopaque = null;
    switch (c.SQLGetDescField(
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
    return fromUsize(FieldType(attr, descriptor_kind), @intFromPtr(value_ptr));
}

fn setFieldGeneric(
    handle: ?*anyopaque,
    col_number: i16,
    comptime attr: anytype,
    comptime descriptor_kind: attrs.StmtAttrHandle,
    value: FieldType(attr, descriptor_kind),
) !void {
    return switch (c.SQLSetDescField(
        handle,
        col_number,
        @intFromEnum(attr),
        @ptrFromInt(toUsize(value)),
        0,
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
    base_column_name = c.SQL_DESC_BASE_COLUMN_NAME,
    base_table_name = c.SQL_DESC_BASE_TABLE_NAME,
    case_sensitive = c.SQL_DESC_CASE_SENSITIVE,
    catalog_name = c.SQL_DESC_CATALOG_NAME,
    concise_type = c.SQL_DESC_CONCISE_TYPE,
    datetime_interval_code = c.SQL_DESC_DATETIME_INTERVAL_CODE,
    datetime_interval_precision = c.SQL_DESC_DATETIME_INTERVAL_PRECISION,
    display_size = c.SQL_DESC_DISPLAY_SIZE,
    fixed_prec_scale = c.SQL_DESC_FIXED_PREC_SCALE,
    label = c.SQL_DESC_LABEL,
    length = c.SQL_DESC_LENGTH,
    literal_prefix = c.SQL_DESC_LITERAL_PREFIX,
    literal_suffix = c.SQL_DESC_LITERAL_SUFFIX,
    local_type_name = c.SQL_DESC_LOCAL_TYPE_NAME,
    name = c.SQL_DESC_NAME,
    nullable = c.SQL_DESC_NULLABLE,
    num_prec_radix = c.SQL_DESC_NUM_PREC_RADIX,
    octet_length = c.SQL_DESC_OCTET_LENGTH,
    precision = c.SQL_DESC_PRECISION,
    rowver = c.SQL_DESC_ROWVER,
    scale = c.SQL_DESC_SCALE,
    schema_name = c.SQL_DESC_SCHEMA_NAME,
    searchable = c.SQL_DESC_SEARCHABLE,
    table_name = c.SQL_DESC_TABLE_NAME,
    type = c.SQL_DESC_TYPE,
    type_name = c.SQL_DESC_TYPE_NAME,
    unnamed = c.SQL_DESC_UNNAMED,
    unsigned = c.SQL_DESC_UNSIGNED,
    updatable = c.SQL_DESC_UPDATABLE,
};

const ReadFieldsImpParamDesc = enum(u15) {
    array_status_ptr = c.SQL_DESC_ARRAY_STATUS_PTR,
    count = c.SQL_DESC_COUNT,
    rows_processed_ptr = c.SQL_DESC_ROWS_PROCESSED_PTR,
    concise_type = c.SQL_DESC_CONCISE_TYPE,
    datetime_interval_code = c.SQL_DESC_DATETIME_INTERVAL_CODE,
    datetime_interval_precision = c.SQL_DESC_DATETIME_INTERVAL_PRECISION,
    length = c.SQL_DESC_LENGTH,
    name = c.SQL_DESC_NAME,
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
    local_type_name = c.SQL_DESC_LOCAL_TYPE_NAME,
    nullable = c.SQL_DESC_NULLABLE,
    rowver = c.SQL_DESC_ROWVER,
    type_name = c.SQL_DESC_TYPE_NAME,
    unsigned = c.SQL_DESC_UNSIGNED,
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
    name = c.SQL_DESC_NAME,
    num_prec_radix = c.SQL_DESC_NUM_PREC_RADIX,
    octet_length = c.SQL_DESC_OCTET_LENGTH,
    parameter_type = c.SQL_DESC_PARAMETER_TYPE,
    precision = c.SQL_DESC_PRECISION,
    scale = c.SQL_DESC_SCALE,
    type = c.SQL_DESC_TYPE,
    unnamed = c.SQL_DESC_UNNAMED,
};

pub const AppRowDesc = struct {
    handler: Handle,

    const Self = @This();

    pub fn fromStatement(stmt: Statement) !Self {
        const handler: Handle = .{
            .handle = try stmt.getStmtAttrHandle(.app_row_desc),
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
        col_number: i16,
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
        col_number: i16,
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
            .handle = try stmt.getStmtAttrHandle(.imp_row_desc),
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
        col_number: i16,
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
        col_number: i16,
        comptime attr: ReadFieldsImpRowDesc,
    ) !FieldType(attr, .imp_row_desc) {
        return try getFieldGeneric(
            self.handle(),
            col_number,
            attr,
            .imp_row_desc,
        );
    }
};

pub const AppParamDesc = struct {
    handler: Handle,

    const Self = @This();

    pub fn fromStatement(stmt: Statement) !Self {
        const handler: Handle = .{
            .handle = try stmt.getStmtAttrHandle(.app_param_desc),
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
        col_number: i16,
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
        col_number: i16,
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
            .handle = try stmt.getStmtAttrHandle(.imp_param_desc),
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
        col_number: i16,
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

    pub fn getField(
        self: Self,
        col_number: i16,
        comptime attr: ReadFieldsImpParamDesc,
    ) !FieldType(attr, .imp_param_desc) {
        return try getFieldGeneric(
            self.handle(),
            col_number,
            attr,
            .imp_param_desc,
        );
    }
};
