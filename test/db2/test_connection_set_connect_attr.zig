const std = @import("std");
const testing = std.testing;
const expectEqual = testing.expectEqual;
const expectError = testing.expectError;
const allocator = testing.allocator;

const zodbc = @import("zodbc");
const err = zodbc.errors;
const attrs = zodbc.odbc.attributes;

const AttributeValue = attrs.ConnectionAttributeValue;

test ".setConnectAttr/1 can modify disconnected items" {
    const env_con = try zodbc.testing.connection();
    defer {
        env_con.con.deinit();
        env_con.env.deinit();
    }
    const con = env_con.con;

    var odbc_buf: [256]u8 = undefined;

    try con.setConnectAttr(.{ .odbc_cursors = .if_needed });
    @memset(odbc_buf[0..], 0);
    const odbc_cursors_value = try con.getConnectAttr(allocator, .odbc_cursors, odbc_buf[0..]);
    defer odbc_cursors_value.deinit(allocator);
    try expectEqual(
        AttributeValue.OdbcCursors.if_needed,
        odbc_cursors_value.odbc_cursors,
    );

    try con.setConnectAttr(.{ .login_timeout = 1000 });
    @memset(odbc_buf[0..], 0);
    const login_timeout_value = try con.getConnectAttr(allocator, .login_timeout, odbc_buf[0..]);
    defer login_timeout_value.deinit(allocator);
    try expectEqual(
        1000,
        login_timeout_value.login_timeout,
    );
}

test ".setConnectAttr/1 can modify connected items" {
    const env_con = try zodbc.testing.connection();
    defer {
        env_con.con.deinit();
        env_con.env.deinit();
    }
    const con = env_con.con;
    const con_str = try zodbc.testing.db2ConnectionString(allocator);
    defer allocator.free(con_str);
    try env_con.con.connectWithString(con_str);

    var odbc_buf: [256]u8 = undefined;

    try con.setConnectAttr(.{ .access_mode = .read_only });
    @memset(odbc_buf[0..], 0);
    const access_mode_value = try con.getConnectAttr(allocator, .access_mode, odbc_buf[0..]);
    defer access_mode_value.deinit(allocator);
    try expectEqual(
        AttributeValue.AccessMode.read_only,
        access_mode_value.access_mode,
    );

    try con.setConnectAttr(.{ .autocommit = .off });
    @memset(odbc_buf[0..], 0);
    const autocommit_value = try con.getConnectAttr(allocator, .autocommit, odbc_buf[0..]);
    defer autocommit_value.deinit(allocator);
    try expectEqual(
        AttributeValue.Autocommit.off,
        autocommit_value.autocommit,
    );

    try con.setConnectAttr(.{ .trace = .on });
    @memset(odbc_buf[0..], 0);
    const trace_value = try con.getConnectAttr(allocator, .trace, odbc_buf[0..]);
    defer trace_value.deinit(allocator);
    try expectEqual(
        AttributeValue.Trace.on,
        trace_value.trace,
    );

    // try con.setConnectAttr(.{ .driver_threading = 1 });
    // @memset(odbc_buf[0..], 0);
    // const driver_threading_value = try con.getConnectAttr(allocator, .driver_threading, odbc_buf[0..]);
    // defer driver_threading_value.deinit(allocator);
    // try expectEqual(
    //     1,
    //     driver_threading_value.driver_threading,
    // );

    try con.setConnectAttr(.{ .connection_timeout = 100 });
    @memset(odbc_buf[0..], 0);
    const connection_timeout_value = try con.getConnectAttr(allocator, .connection_timeout, odbc_buf[0..]);
    defer connection_timeout_value.deinit(allocator);
    try expectEqual(100, connection_timeout_value.connection_timeout);

    // try con.setConnectAttr(.{ .disconnect_behavior = .disconnect });
    // @memset(odbc_buf[0..], 0);
    // const disconnect_behavior_info = try con.getConnectAttr(allocator, .disconnect_behavior, odbc_buf[0..]);
    // defer disconnect_behavior_info.deinit(allocator);
    // try expectEqual(
    //     AttributeValue.DisconnectBehavior.disconnect,
    //     disconnect_behavior_info.disconnect_behavior,
    // );

    // try con.setConnectAttr(.{ .enlist_in_dtc = .unenlist_expensive });
    // @memset(odbc_buf[0..], 0);
    // const enlist_in_dtc_value = try con.getConnectAttr(allocator, .enlist_in_dtc, odbc_buf[0..]);
    // defer enlist_in_dtc_value.deinit(allocator);
    // try expectEqual(
    //     AttributeValue.EnlistInDtc.enlist_expensive,
    //     enlist_in_dtc_value.enlist_in_dtc,
    // );

    try con.setConnectAttr(.{ .txn_isolation = .read_uncommitted });
    @memset(odbc_buf[0..], 0);
    const txn_isolation_value = try con.getConnectAttr(allocator, .txn_isolation, odbc_buf[0..]);
    defer txn_isolation_value.deinit(allocator);
    try expectEqual(
        AttributeValue.TxnIsolation.read_uncommitted,
        txn_isolation_value.txn_isolation,
    );

    try con.setConnectAttr(.{ .ansi_app = .false });
    @memset(odbc_buf[0..], 0);
    const ansi_app_value = try con.getConnectAttr(allocator, .ansi_app, odbc_buf[0..]);
    defer ansi_app_value.deinit(allocator);
    try expectEqual(
        AttributeValue.AnsiApp.false,
        ansi_app_value.ansi_app,
    );

    try con.setConnectAttr(.{ .async_enable = .on });
    @memset(odbc_buf[0..], 0);
    const async_enable_value = try con.getConnectAttr(allocator, .async_enable, odbc_buf[0..]);
    defer async_enable_value.deinit(allocator);
    try expectEqual(
        AttributeValue.AsyncEnable.on,
        async_enable_value.async_enable,
    );

    // try con.setConnectAttr(.{ .reset_connection = .yes });
    // @memset(odbc_buf[0..], 0);
    // const reset_connection_value = try con.getConnectAttr(allocator, .reset_connection, odbc_buf[0..]);
    // defer reset_connection_value.deinit(allocator);
    // try expectEqual(
    //     AttributeValue.ResetConnection.yes,
    //     reset_connection_value.reset_connection,
    // );

    try con.setConnectAttr(.{ .async_dbc_functions_enable = .on });
    @memset(odbc_buf[0..], 0);
    const async_dbc_functions_enable_value = try con.getConnectAttr(allocator, .async_dbc_functions_enable, odbc_buf[0..]);
    defer async_dbc_functions_enable_value.deinit(allocator);
    try expectEqual(
        AttributeValue.AsyncDbcFunctionsEnable.on,
        async_dbc_functions_enable_value.async_dbc_functions_enable,
    );
}

test ".setConnectAttr/1 can modify disconnected Db2 specific items" {
    const env_con = try zodbc.testing.connection();
    defer {
        env_con.con.deinit();
        env_con.env.deinit();
    }
    const con = env_con.con;

    var odbc_buf: [256]u8 = undefined;

    try con.setConnectAttr(.{ .fet_buf_size = 131072 });
    @memset(odbc_buf[0..], 0);
    const fet_buf_size_value = try con.getConnectAttr(allocator, .fet_buf_size, odbc_buf[0..]);
    defer fet_buf_size_value.deinit(allocator);
    try expectEqual(
        131072,
        fet_buf_size_value.fet_buf_size,
    );
}

test "setConnectAttr/1 returns an error when item is immutable" {
    const env_con = try zodbc.testing.connection();
    defer {
        env_con.con.deinit();
        env_con.env.deinit();
    }
    const con = env_con.con;
    const con_str = try zodbc.testing.db2ConnectionString(allocator);
    defer allocator.free(con_str);
    try con.connectWithString(con_str);

    try expectError(
        err.SetConnectAttrError.Error,
        con.setConnectAttr(.{ .connection_dead = .true }),
    );

    try expectError(
        err.SetConnectAttrError.Error,
        con.setConnectAttr(.{ .auto_ipd = .true }),
    );
}
