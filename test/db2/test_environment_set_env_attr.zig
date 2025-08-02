const std = @import("std");
const testing = std.testing;
const expectEqual = testing.expectEqual;
const expectError = testing.expectError;
const allocator = testing.allocator;

const zodbc = @import("zodbc");
const err = zodbc.errors;
const attrs = zodbc.odbc.attributes;

const AttributeValue = attrs.EnvironmentAttributeValue;

test "setEnvAttr/1 can modify items that will be shared among connections" {
    const env = try zodbc.testing.environment();
    defer env.deinit() catch unreachable;

    var odbc_buf: [256]u8 = undefined;

    try env.setEnvAttr(.{ .odbc_version = .v2 });
    @memset(odbc_buf[0..], 0);
    const odbc_version_value = try env.getEnvAttr(allocator, .odbc_version, odbc_buf[0..]);
    defer odbc_version_value.deinit(allocator);
    try expectEqual(
        AttributeValue.OdbcVersion.v2,
        odbc_version_value.odbc_version,
    );

    try env.setEnvAttr(.{ .connection_pooling = .one_per_driver });
    @memset(odbc_buf[0..], 0);
    const connection_pooling_value = try env.getEnvAttr(allocator, .connection_pooling, odbc_buf[0..]);
    defer connection_pooling_value.deinit(allocator);
    try expectEqual(
        AttributeValue.ConnectionPooling.one_per_driver,
        connection_pooling_value.connection_pooling,
    );

    try env.setEnvAttr(.{ .cp_match = .relaxed_match });
    @memset(odbc_buf[0..], 0);
    const cp_match_value = try env.getEnvAttr(allocator, .cp_match, odbc_buf[0..]);
    defer cp_match_value.deinit(allocator);
    try expectEqual(
        AttributeValue.CpMatch.relaxed_match,
        cp_match_value.cp_match,
    );
}

test "setEnvAttr/1 returns an error for unixODBC items" {
    const env = try zodbc.testing.environment();
    defer env.deinit() catch unreachable;

    try expectError(
        err.SetEnvAttrError.Error,
        env.setEnvAttr(.{ .unixodbc_syspath = "/new/path" }),
    );

    try expectError(
        err.SetEnvAttrError.Error,
        env.setEnvAttr(.{ .unixodbc_version = "1234" }),
    );

    try expectError(
        err.SetEnvAttrError.Error,
        env.setEnvAttr(.{ .unixodbc_envattr = "FOO=BAR" }),
    );
}

// By default Db2 is set to return null terminated strings. The IBM documentation claims
// that you can disable null terminated strings but `SQLSetEnvAttr` through unixODBC
// returns an error with the message:
//
// `[unixODBC][Driver Manager]Optional feature not implemented`
//
// - https://www.ibm.com/docs/en/db2-for-zos/11?topic=functions-sqlsetenvattr-set-environment-attributes
test "setEnvAttr/1 returns an error when null terminated output is false" {
    const env = try zodbc.testing.environment();
    defer env.deinit() catch unreachable;

    var odbc_buf: [256]u8 = undefined;

    try env.setEnvAttr(.{ .output_nts = .true });
    @memset(odbc_buf[0..], 0);
    const output_nts_value = try env.getEnvAttr(allocator, .output_nts, odbc_buf[0..]);
    defer output_nts_value.deinit(allocator);
    try expectEqual(
        AttributeValue.OutputNts.true,
        output_nts_value.output_nts,
    );

    try expectError(
        err.SetEnvAttrError.Error,
        env.setEnvAttr(.{ .output_nts = .false }),
    );
}
