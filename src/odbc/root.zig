pub const types = @import("types.zig");
pub const attributes = @import("attributes.zig");
pub const info = @import("info.zig");
pub const return_codes = @import("return_codes.zig");
pub const sql = @import("sql.zig");
pub const mem = @import("mem.zig");
pub const c = @import("c");
const std = @import("std");

pub fn msodbcsql_h(value: comptime_int, field_name: []const u8) comptime_int {
    if (!@hasDecl(c, "SQLODBC_PRODUCT_NAME_SHORT_ANSI"))
        return value;
    if (!std.mem.eql(
        u8,
        @field(c, "SQLODBC_PRODUCT_NAME_SHORT_ANSI"),
        "ODBC Driver for SQL Server",
    ))
        return value;
    const actual_value = @field(c, field_name);
    if (actual_value != value) {
        @compileError(std.fmt.comptimePrint(
            "Field: {s}, got {} expected {}\n",
            .{ field_name, actual_value, value },
        ));
    }
    return value;
}

pub fn opt_h(value: comptime_int, field_name: []const u8) comptime_int {
    if (@hasDecl(c, field_name)) {
        const actual_value = @field(c, field_name);
        if (actual_value != value) {
            @compileError(std.fmt.comptimePrint(
                "Field: {s}, got {} expected {}\n",
                .{ field_name, actual_value, value },
            ));
        }
    }
    return value;
}
