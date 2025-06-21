const std = @import("std");

pub inline fn fromUsize(T: type, val: usize) T {
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

pub inline fn toUsize(val: anytype) usize {
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
