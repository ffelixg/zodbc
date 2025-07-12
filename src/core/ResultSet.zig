const std = @import("std");
const core = @import("root.zig");
const odbc = @import("odbc");
const CDataType = odbc.types.CDataType;
const c = odbc.c;
const mem = odbc.mem;
const RowStatus = odbc.attributes.RowStatus;

const ResultSet = @This();

const Column = struct {
    c_type: CDataType,
    buf_indicator: []i64,
    buf_value: []u8,
    value_size: usize,
    type_specific: ?union(TypeSpecific) {
        decimal: struct {
            precision: u6,
            scale: i7,
        },
    } = null,

    const TypeSpecific = enum { decimal };

    pub fn deinit(self: Column, allocator: std.mem.Allocator) void {
        self.c_type.free(allocator, self.buf_value);
        allocator.free(self.buf_indicator);
    }
};

odbc_buf_rows: usize,
next_row: usize,
n_cols: usize,
n_cols_bound: usize,
stmt: core.Statement,
desc: core.Descriptor.AppRowDesc,
columns: std.ArrayListUnmanaged(Column),
array_status: []RowStatus,
borrowed_row: []?[]u8,
allocator: std.mem.Allocator,

pub fn init(stmt: core.Statement, allocator: std.mem.Allocator) !ResultSet {
    errdefer stmt.free(.unbind) catch {};
    const desc = try core.Descriptor.AppRowDesc.fromStatement(stmt);
    const n_cols = try stmt.numResultCols();
    var n_cols_bound: usize = n_cols;

    const c_types = try allocator.alloc(struct { format: CDataType, len: usize }, n_cols);
    defer allocator.free(c_types);

    for (c_types, 0..) |*c_type, col_number_usize| {
        const col_number: u15 = @intCast(1 + col_number_usize);
        const sql_type = try stmt.colAttribute(col_number, .concise_type);
        const format: CDataType = switch (sql_type) {
            .float => .double,
            .tinyint => if (try stmt.colAttribute(col_number, .unsigned)) .utinyint else .stinyint,
            .smallint => if (try stmt.colAttribute(col_number, .unsigned)) .ushort else .sshort,
            .integer => if (try stmt.colAttribute(col_number, .unsigned)) .ulong else .slong,
            .bigint => if (try stmt.colAttribute(col_number, .unsigned)) .ubigint else .sbigint,
            .real => .float,
            .double => .double,
            .bit => .bit,
            .decimal, .numeric => .numeric,
            .type_date => .type_date,
            .type_time => .type_time,
            .type_timestamp, .datetime => .type_timestamp,
            .char, .varchar, .longvarchar => .wchar,
            .wchar, .wvarchar, .wlongvarchar => .wchar,
            .binary, .varbinary, .longvarbinary => .binary,
            .guid => .guid,
            .ss_time2 => .ss_time2,
            .ss_timestampoffset => .ss_timestampoffset,
            else => @panic("unsupported type"),
        };
        c_type.* = .{ .format = format, .len = blk: {
            const null_terminator: u1 = switch (format) {
                .binary => 0,
                .char, .wchar => 1,
                else => break :blk 1,
            };
            const length = try stmt.colAttribute(col_number, .length);
            const precision = try stmt.colAttribute(col_number, .precision);
            std.debug.assert(length == precision);
            std.debug.assert(length >= 0);
            if (length == 0 or length > 4000) {
                n_cols_bound = @min(n_cols_bound, col_number_usize);
                break :blk 4000;
            } else {
                break :blk @intCast(length + null_terminator);
            }
        } };
    }

    var columns = try std.ArrayListUnmanaged(Column).initCapacity(allocator, n_cols);
    errdefer columns.deinit(allocator);
    errdefer for (columns.items) |col| col.deinit(allocator);

    const odbc_buf_rows: usize = if (n_cols_bound == n_cols) 1 + @divFloor(69, n_cols) else 1;

    for (c_types, 0..) |c_type, col_number_usize| {
        const col_number: u15 = @intCast(1 + col_number_usize);

        const col_odbc_buffer = try c_type.format.alloc(allocator, odbc_buf_rows * c_type.len);
        errdefer c_type.format.free(allocator, col_odbc_buffer);
        const col_odbc_indicator = try allocator.alloc(i64, odbc_buf_rows);
        errdefer allocator.free(col_odbc_indicator);

        try desc.setField(col_number, .concise_type, c_type.format);

        const type_specific: @FieldType(Column, "type_specific") = switch (c_type.format) {
            .numeric => blk: {
                const precision = try stmt.colAttribute(col_number, .precision);
                try desc.setField(col_number, .precision, @intCast(precision));
                const scale = try stmt.colAttribute(col_number, .scale);
                try desc.setField(col_number, .scale, @intCast(scale));
                break :blk .{ .decimal = .{ .precision = @intCast(precision), .scale = @intCast(scale) } };
            },
            else => null,
        };
        if (col_number_usize < n_cols_bound) {
            try desc.setField(col_number, .octet_length, @intCast(@divExact(col_odbc_buffer.len, odbc_buf_rows)));
            try desc.setField(col_number, .indicator_ptr, col_odbc_indicator.ptr);
            switch (c_type.format) {
                .char, .wchar, .binary => try desc.setField(col_number, .octet_length_ptr, col_odbc_indicator.ptr),
                else => {},
            }
            try desc.setField(col_number, .data_ptr, col_odbc_buffer.ptr);
        }
        columns.appendAssumeCapacity(.{
            .c_type = c_type.format,
            .buf_indicator = col_odbc_indicator,
            .buf_value = col_odbc_buffer,
            .value_size = c_type.len * c_type.format.sizeOf(),
            .type_specific = type_specific,
        });
    }
    const array_status = try allocator.alloc(RowStatus, odbc_buf_rows * 1000);
    errdefer allocator.free(array_status);
    try stmt.setStmtAttr(.row_bind_type, 0);
    try stmt.setStmtAttr(.row_status_ptr, array_status.ptr);
    try stmt.setStmtAttr(.row_array_size, odbc_buf_rows);
    return .{
        .stmt = stmt,
        .desc = desc,
        .odbc_buf_rows = odbc_buf_rows,
        // Means that no data is loaded into the buffers yet.
        .next_row = odbc_buf_rows,
        .n_cols = n_cols,
        .n_cols_bound = n_cols_bound,
        .columns = columns,
        .array_status = array_status,
        .borrowed_row = try allocator.alloc(?[]u8, n_cols),
        .allocator = allocator,
    };
}

pub fn deinit(self: *ResultSet) !void {
    const allocator = self.allocator;
    for (self.columns.items) |col| col.deinit(allocator);
    self.columns.deinit(allocator);
    allocator.free(self.borrowed_row);
    allocator.free(self.array_status);
    try self.stmt.free(.unbind);
}

pub fn borrowRow(res: *@This()) !?[]?[]u8 {
    if (res.next_row >= res.odbc_buf_rows) {
        std.debug.assert(res.next_row == res.odbc_buf_rows);
        {
            res.stmt.fetch() catch |err| switch (err) {
                error.FetchNoData => return null,
                else => return err,
            };
        }
        if (res.n_cols_bound != res.n_cols) {
            std.debug.assert(res.n_cols_bound < res.n_cols);
            std.debug.assert(res.odbc_buf_rows == 1);
            for (res.n_cols_bound..res.n_cols) |i_col| {
                const col = &res.columns.items[i_col];

                switch (col.c_type) {
                    .char, .binary, .wchar => try res.stmt.getDataVar(
                        @intCast(i_col + 1),
                        col.c_type,
                        &col.buf_value,
                        &col.buf_indicator[0],
                        res.allocator,
                    ),
                    else => try res.stmt.getData(
                        @intCast(i_col + 1),
                        .ard_type,
                        col.buf_value,
                        &col.buf_indicator[0],
                    ),
                }
            }
            res.array_status[0] = .success;
        }
        res.next_row = 0;
    }

    switch (res.array_status[res.next_row]) {
        .success => {},
        .success_with_info, .err => return error.ArrayStatusError,
        .norow => return null,
        else => unreachable,
    }

    for (res.borrowed_row, res.columns.items) |*borrowed_row, col| {
        const indicator = col.buf_indicator[res.next_row];
        if (indicator == c.SQL_NULL_DATA) {
            borrowed_row.* = null;
            continue;
        }
        std.debug.assert(indicator >= 0);
        const cell_size = @divExact(col.buf_value.len, res.odbc_buf_rows);
        switch (col.c_type) {
            .char, .binary, .wchar => {
                borrowed_row.* = col.buf_value[res.next_row * cell_size .. res.next_row * cell_size + @as(usize, @intCast(indicator))];
            },
            else => {
                borrowed_row.* = col.buf_value[res.next_row * cell_size .. (res.next_row + 1) * cell_size];
            },
        }
    }

    res.next_row += 1;
    return res.borrowed_row;
}
