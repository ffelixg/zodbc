const std = @import("std");
const testing = std.testing;
const expectEqual = testing.expectEqual;
const expectEqualStrings = testing.expectEqualStrings;
const expectError = testing.expectError;
const allocator = testing.allocator;

const zodbc = @import("zodbc");
const err = zodbc.errors;
const attrs = zodbc.odbc.attributes;

const AttributeValue = attrs.EnvironmentAttributeValue;

test "getEnvAttr/3 can retrieve the current item values" {
    const env = try zodbc.testing.environment();
    defer env.deinit();

    var odbc_buf: [256]u8 = undefined;

    @memset(odbc_buf[0..], 0);
    const odbc_version_value = try env.getEnvAttr(allocator, .odbc_version, odbc_buf[0..]);
    defer odbc_version_value.deinit(allocator);
    try expectEqual(
        AttributeValue.OdbcVersion.v3,
        odbc_version_value.odbc_version,
    );

    @memset(odbc_buf[0..], 0);
    const output_nts_value = try env.getEnvAttr(allocator, .output_nts, odbc_buf[0..]);
    defer output_nts_value.deinit(allocator);
    try expectEqual(
        AttributeValue.OutputNts.true,
        output_nts_value.output_nts,
    );

    @memset(odbc_buf[0..], 0);
    const connection_pooling_value = try env.getEnvAttr(allocator, .connection_pooling, odbc_buf[0..]);
    defer connection_pooling_value.deinit(allocator);
    try expectEqual(
        AttributeValue.ConnectionPooling.off,
        connection_pooling_value.connection_pooling,
    );

    @memset(odbc_buf[0..], 0);
    const cp_match_value = try env.getEnvAttr(allocator, .cp_match, odbc_buf[0..]);
    defer cp_match_value.deinit(allocator);
    try expectEqual(
        AttributeValue.CpMatch.strict_match,
        cp_match_value.cp_match,
    );

    @memset(odbc_buf[0..], 0);
    const unixodbc_syspath_value = try env.getEnvAttr(allocator, .unixodbc_syspath, odbc_buf[0..]);
    defer unixodbc_syspath_value.deinit(allocator);
    try expectEqualStrings(
        "/etc",
        unixodbc_syspath_value.unixodbc_syspath,
    );

    @memset(odbc_buf[0..], 0);
    const unixodbc_version_value = try env.getEnvAttr(allocator, .unixodbc_version, odbc_buf[0..]);
    defer unixodbc_version_value.deinit(allocator);
    try expectEqualStrings(
        "2.3.12",
        unixodbc_version_value.unixodbc_version,
    );
}

test "getEnvAttr/3 returns an error for unsupported items" {
    const env = try zodbc.testing.environment();
    defer env.deinit();

    var odbc_buf: [256]u8 = undefined;

    @memset(odbc_buf[0..], 0);
    try expectError(
        err.GetEnvAttrError.Error,
        env.getEnvAttr(allocator, .unixodbc_envattr, odbc_buf[0..]),
    );
}
