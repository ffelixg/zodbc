const std = @import("std");
const zig_cli = @import("zig-cli");
const app = @import("app.zig");

pub fn run(allocator: std.mem.Allocator) !void {
    var runner = try zig_cli.AppRunner.init(allocator);
    try runner.run(app.app);
}
