const std = @import("std");
const testing = std.testing;
const expectEqual = testing.expectEqual;
const expectError = testing.expectError;
const allocator = testing.allocator;

const zodbc = @import("zodbc");
const err = zodbc.errors;
const attrs = zodbc.odbc.attributes;

const AttributeValue = attrs.ConnectionAttributeValue;

test "getConnectAttr/3 can retrieve the current item values for disconnected connections" {
    const env_con = try zodbc.testing.connection();
    defer {
        env_con.con.deinit() catch unreachable;
        env_con.env.deinit() catch unreachable;
    }
    const con = env_con.con;

    var odbc_buf: [256]u8 = undefined;

    @memset(odbc_buf[0..], 0);
    const access_mode_value = try con.getConnectAttr(allocator, .access_mode, odbc_buf[0..]);
    defer access_mode_value.deinit(allocator);
    try expectEqual(
        AttributeValue.AccessMode.read_write,
        access_mode_value.access_mode,
    );

    @memset(odbc_buf[0..], 0);
    const autocommit_value = try con.getConnectAttr(allocator, .autocommit, odbc_buf[0..]);
    defer autocommit_value.deinit(allocator);
    try expectEqual(
        AttributeValue.Autocommit.on,
        autocommit_value.autocommit,
    );

    @memset(odbc_buf[0..], 0);
    const odbc_cursors_value = try con.getConnectAttr(allocator, .odbc_cursors, odbc_buf[0..]);
    defer odbc_cursors_value.deinit(allocator);
    try expectEqual(
        AttributeValue.OdbcCursors.use_driver,
        odbc_cursors_value.odbc_cursors,
    );

    @memset(odbc_buf[0..], 0);
    const trace_value = try con.getConnectAttr(allocator, .trace, odbc_buf[0..]);
    defer trace_value.deinit(allocator);
    try expectEqual(
        AttributeValue.Trace.off,
        trace_value.trace,
    );
}

test "getConnectAttr/3 can retrieve connected items" {
    const env_con = try zodbc.testing.connection();
    defer {
        env_con.con.deinit() catch unreachable;
        env_con.env.deinit() catch unreachable;
    }
    const con = env_con.con;
    const con_str = try zodbc.testing.db2ConnectionString(allocator);
    defer allocator.free(con_str);
    try con.connectWithString(con_str);

    var odbc_buf: [256]u8 = undefined;

    @memset(odbc_buf[0..], 0);
    const connection_dead_value = try con.getConnectAttr(allocator, .connection_dead, odbc_buf[0..]);
    defer connection_dead_value.deinit(allocator);
    try expectEqual(
        AttributeValue.ConnectionDead.false,
        connection_dead_value.connection_dead,
    );

    // @memset(odbc_buf[0..], 0);
    // const driver_threading_value = try con.getConnectAttr(allocator, .driver_threading, odbc_buf[0..]);
    // defer driver_threading_value.deinit(allocator);
    // try expectEqual(1, driver_threading_value.driver_threading);

    @memset(odbc_buf[0..], 0);
    const connection_timeout_value = try con.getConnectAttr(allocator, .connection_timeout, odbc_buf[0..]);
    defer connection_timeout_value.deinit(allocator);
    try expectEqual(0, connection_timeout_value.connection_timeout);

    // TODO:
    // - does this option require driver level connection pooling to be enabled?
    // @memset(odbc_buf[0..], 0);
    // const disconnect_behavior_value = try con.getConnectAttr(allocator, .disconnect_behavior, odbc_buf[0..]);
    // defer disconnect_behavior_value.deinit(allocator);
    // try expectEqual(
    //     AttributeValue.DisconnectBehavior.return_to_pool,
    //     disconnect_behavior_value.disconnect_behavior,
    // );

    // TODO:
    // - figure out why this gets option out of range erro
    // @memset(odbc_buf[0..], 0);
    // const enlist_in_dtc_value = try con.getConnectAttr(allocator, .enlist_in_dtc, odbc_buf[0..]);
    // defer enlist_in_dtc_value.deinit(allocator);
    // try expectEqual(
    //     AttributeValue.EnlistInDtc.enlist_expensive,
    //     enlist_in_dtc_value.enlist_in_dtc,
    // );

    @memset(odbc_buf[0..], 0);
    const login_timeout_value = try con.getConnectAttr(allocator, .login_timeout, odbc_buf[0..]);
    defer login_timeout_value.deinit(allocator);
    try expectEqual(0, login_timeout_value.login_timeout);

    @memset(odbc_buf[0..], 0);
    const txn_isolation_value = try con.getConnectAttr(allocator, .txn_isolation, odbc_buf[0..]);
    defer txn_isolation_value.deinit(allocator);
    try expectEqual(
        AttributeValue.TxnIsolation.read_committed,
        txn_isolation_value.txn_isolation,
    );

    @memset(odbc_buf[0..], 0);
    const ansi_app_value = try con.getConnectAttr(allocator, .ansi_app, odbc_buf[0..]);
    defer ansi_app_value.deinit(allocator);
    try expectEqual(
        AttributeValue.AnsiApp.true,
        ansi_app_value.ansi_app,
    );

    @memset(odbc_buf[0..], 0);
    const async_enable_value = try con.getConnectAttr(allocator, .async_enable, odbc_buf[0..]);
    defer async_enable_value.deinit(allocator);
    try expectEqual(
        AttributeValue.AsyncEnable.off,
        async_enable_value.async_enable,
    );

    @memset(odbc_buf[0..], 0);
    const auto_ipd_value = try con.getConnectAttr(allocator, .auto_ipd, odbc_buf[0..]);
    defer auto_ipd_value.deinit(allocator);
    try expectEqual(
        AttributeValue.AutoIpd.true,
        auto_ipd_value.auto_ipd,
    );

    // @memset(odbc_buf[0..], 0);
    // const reset_connection_value = try con.getConnectAttr(allocator, .reset_connection, odbc_buf[0..]);
    // defer reset_connection_value.deinit(allocator);
    // try expectEqual(
    //     AttributeValue.ResetConnection.yes,
    //     reset_connection_value.reset_connection,
    // );

    @memset(odbc_buf[0..], 0);
    const async_dbc_functions_enable_value = try con.getConnectAttr(allocator, .async_dbc_functions_enable, odbc_buf[0..]);
    defer async_dbc_functions_enable_value.deinit(allocator);
    try expectEqual(
        AttributeValue.AsyncDbcFunctionsEnable.off,
        async_dbc_functions_enable_value.async_dbc_functions_enable,
    );
}

test "getConnectAttr/3 can retrieve Db2 specific items" {
    const env_con = try zodbc.testing.connection();
    defer {
        env_con.con.deinit() catch unreachable;
        env_con.env.deinit() catch unreachable;
    }
    const con = env_con.con;
    const con_str = try zodbc.testing.db2ConnectionString(allocator);
    defer allocator.free(con_str);
    try con.connectWithString(con_str);

    var odbc_buf: [256]u8 = undefined;

    @memset(odbc_buf[0..], 0);
    const fet_buf_size_value = try con.getConnectAttr(allocator, .fet_buf_size, odbc_buf[0..]);
    defer fet_buf_size_value.deinit(allocator);
    try expectEqual(65536, fet_buf_size_value.fet_buf_size);
}

// IBM Db2 doesn't support SQL_ATTR_PACKET_SIZE
//
// - https://www.ibm.com/docs/en/db2/10.1.0?topic=attributes-connection-list
test "getConnectAttr/3 returns a not implemented error for unsupported items" {
    const env_con = try zodbc.testing.connection();
    defer {
        env_con.con.deinit() catch unreachable;
        env_con.env.deinit() catch unreachable;
    }
    const con = env_con.con;
    const con_str = try zodbc.testing.db2ConnectionString(allocator);
    defer allocator.free(con_str);
    try con.connectWithString(con_str);

    var odbc_buf: [256]u8 = undefined;

    @memset(odbc_buf[0..], 0);
    try expectError(
        err.SetConnectAttrError.Error,
        con.getConnectAttr(allocator, .packet_size, odbc_buf[0..]),
    );
}
