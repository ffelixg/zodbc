const std = @import("std");
const sql = @import("odbc").sql;

pub const errors = @import("errors.zig");
pub const Environment = @import("Environment.zig");
pub const Connection = @import("Connection.zig");
pub const Statement = @import("Statement.zig");
pub const Descriptor = @import("Descriptor.zig");

pub fn getDiagRecs(has_handler: anytype, allocator: std.mem.Allocator) !sql.DiagRecs {
    const handle = has_handler.handler;
    return try sql.DiagRecs.init(handle.handle_type, handle.handle, allocator);
}

pub const Rowset = @import("Rowset.zig");
pub const ResultSet = @import("ResultSet.zig");
