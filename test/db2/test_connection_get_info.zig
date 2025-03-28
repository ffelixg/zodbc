const std = @import("std");
const testing = std.testing;
const expect = testing.expect;
const expectEqual = testing.expectEqual;
const expectEqualStrings = testing.expectEqualStrings;
const expectEqualSlices = testing.expectEqualSlices;
const allocator = testing.allocator;

const zodbc = @import("zodbc");
const info = zodbc.odbc.info;

const InfoTypeValue = info.InfoTypeValue;

test "getInfo/3 returns general information about the connected DBMS" {
    const env_con = try zodbc.testing.connection();
    defer {
        env_con.con.deinit();
        env_con.env.deinit();
    }
    const con = env_con.con;
    const con_str = try zodbc.testing.db2ConnectionString(allocator);
    defer allocator.free(con_str);
    try con.connectWithString(con_str);

    var odbc_buf: [2048]u8 = undefined;

    @memset(odbc_buf[0..], 0);
    const accessible_procedures_info = try con.getInfo(allocator, .accessible_procedures, odbc_buf[0..]);
    defer accessible_procedures_info.deinit(allocator);
    try expectEqual(false, accessible_procedures_info.accessible_procedures);

    @memset(odbc_buf[0..], 0);
    const accessible_tables_info = try con.getInfo(allocator, .accessible_tables, odbc_buf[0..]);
    defer accessible_tables_info.deinit(allocator);
    try expectEqual(false, accessible_tables_info.accessible_tables);

    @memset(odbc_buf[0..], 0);
    const active_environments_info = try con.getInfo(allocator, .active_environments, odbc_buf[0..]);
    defer active_environments_info.deinit(allocator);
    try expectEqual(1, active_environments_info.active_environments);

    @memset(odbc_buf[0..], 0);
    const aggregate_functions_info = try con.getInfo(allocator, .aggregate_functions, odbc_buf[0..]);
    defer aggregate_functions_info.deinit(allocator);
    try expectEqual(
        InfoTypeValue.AggregateFunctionsMask{ .data = 64 },
        aggregate_functions_info.aggregate_functions,
    );

    @memset(odbc_buf[0..], 0);
    const alter_domain_info = try con.getInfo(allocator, .alter_domain, odbc_buf[0..]);
    defer alter_domain_info.deinit(allocator);
    try expectEqual(
        InfoTypeValue.AlterDomainMask{ .data = 0 },
        alter_domain_info.alter_domain,
    );

    @memset(odbc_buf[0..], 0);
    const alter_table_info = try con.getInfo(allocator, .alter_table, odbc_buf[0..]);
    defer alter_table_info.deinit(allocator);
    try expectEqual(
        InfoTypeValue.AlterTableMask{ .data = 61545 },
        alter_table_info.alter_table,
    );

    @memset(odbc_buf[0..], 0);
    const batch_row_count_info = try con.getInfo(allocator, .batch_row_count, odbc_buf[0..]);
    defer batch_row_count_info.deinit(allocator);
    try expectEqual(
        InfoTypeValue.BatchRowCountMask{ .data = 4 },
        batch_row_count_info.batch_row_count,
    );

    @memset(odbc_buf[0..], 0);
    const batch_support_info = try con.getInfo(allocator, .batch_support, odbc_buf[0..]);
    defer batch_support_info.deinit(allocator);
    try expectEqual(
        InfoTypeValue.BatchSupportMask{ .data = 7 },
        batch_support_info.batch_support,
    );

    @memset(odbc_buf[0..], 0);
    const bookmark_persistence_info = try con.getInfo(allocator, .bookmark_persistence, odbc_buf[0..]);
    defer bookmark_persistence_info.deinit(allocator);
    try expectEqual(
        InfoTypeValue.BookmarkPersistenceMask{ .data = 90 },
        bookmark_persistence_info.bookmark_persistence,
    );

    @memset(odbc_buf[0..], 0);
    const catalog_location_info = try con.getInfo(allocator, .catalog_location, odbc_buf[0..]);
    defer catalog_location_info.deinit(allocator);
    try expectEqual(0, catalog_location_info.catalog_location);

    @memset(odbc_buf[0..], 0);
    const catalog_name_info = try con.getInfo(allocator, .catalog_name, odbc_buf[0..]);
    defer catalog_name_info.deinit(allocator);
    try expectEqual(false, catalog_name_info.catalog_name);

    @memset(odbc_buf[0..], 0);
    const catalog_name_separator_info = try con.getInfo(allocator, .catalog_name_separator, odbc_buf[0..]);
    defer catalog_name_separator_info.deinit(allocator);
    try expectEqualStrings(".", catalog_name_separator_info.catalog_name_separator);

    @memset(odbc_buf[0..], 0);
    const catalog_term_info = try con.getInfo(allocator, .catalog_term, odbc_buf[0..]);
    defer catalog_term_info.deinit(allocator);
    try expectEqualStrings("", catalog_term_info.catalog_term);

    @memset(odbc_buf[0..], 0);
    const catalog_usage_info = try con.getInfo(allocator, .catalog_usage, odbc_buf[0..]);
    defer catalog_usage_info.deinit(allocator);
    try expectEqual(
        InfoTypeValue.CatalogUsageMask{ .data = 0 },
        catalog_usage_info.catalog_usage,
    );

    @memset(odbc_buf[0..], 0);
    const collation_seq_info = try con.getInfo(allocator, .collation_seq, odbc_buf[0..]);
    defer collation_seq_info.deinit(allocator);
    try expectEqualStrings("", collation_seq_info.collation_seq);

    @memset(odbc_buf[0..], 0);
    const column_alias_info = try con.getInfo(allocator, .column_alias, odbc_buf[0..]);
    defer column_alias_info.deinit(allocator);
    try expectEqual(true, column_alias_info.column_alias);

    @memset(odbc_buf[0..], 0);
    const concat_null_behavior_info = try con.getInfo(allocator, .concat_null_behavior, odbc_buf[0..]);
    defer concat_null_behavior_info.deinit(allocator);
    try expectEqual(
        InfoTypeValue.ConcatNullBehavior.null,
        concat_null_behavior_info.concat_null_behavior,
    );

    @memset(odbc_buf[0..], 0);
    const convert_bigint_info = try con.getInfo(allocator, .convert_bigint, odbc_buf[0..]);
    defer convert_bigint_info.deinit(allocator);
    try expectEqual(
        InfoTypeValue.ConvertBigintMask{ .data = 0 },
        convert_bigint_info.convert_bigint,
    );

    @memset(odbc_buf[0..], 0);
    const convert_binary_info = try con.getInfo(allocator, .convert_binary, odbc_buf[0..]);
    defer convert_binary_info.deinit(allocator);
    try expectEqual(
        InfoTypeValue.ConvertBinaryMask{ .data = 0 },
        convert_binary_info.convert_binary,
    );

    @memset(odbc_buf[0..], 0);
    const convert_bit_info = try con.getInfo(allocator, .convert_bit, odbc_buf[0..]);
    defer convert_bit_info.deinit(allocator);
    try expectEqual(
        InfoTypeValue.ConvertBitMask{ .data = 0 },
        convert_bit_info.convert_bit,
    );

    @memset(odbc_buf[0..], 0);
    const convert_char_info = try con.getInfo(allocator, .convert_char, odbc_buf[0..]);
    defer convert_char_info.deinit(allocator);
    try expectEqual(
        InfoTypeValue.ConvertCharMask{ .data = 129 },
        convert_char_info.convert_char,
    );

    @memset(odbc_buf[0..], 0);
    const convert_date_info = try con.getInfo(allocator, .convert_date, odbc_buf[0..]);
    defer convert_date_info.deinit(allocator);
    try expectEqual(
        InfoTypeValue.ConvertDateMask{ .data = 1 },
        convert_date_info.convert_date,
    );

    @memset(odbc_buf[0..], 0);
    const convert_decimal_info = try con.getInfo(allocator, .convert_decimal, odbc_buf[0..]);
    defer convert_decimal_info.deinit(allocator);
    try expectEqual(
        InfoTypeValue.ConvertDecimalMask{ .data = 129 },
        convert_decimal_info.convert_decimal,
    );

    @memset(odbc_buf[0..], 0);
    const convert_double_info = try con.getInfo(allocator, .convert_double, odbc_buf[0..]);
    defer convert_double_info.deinit(allocator);
    try expectEqual(
        InfoTypeValue.ConvertDoubleMask{ .data = 129 },
        convert_double_info.convert_double,
    );

    @memset(odbc_buf[0..], 0);
    const convert_float_info = try con.getInfo(allocator, .convert_float, odbc_buf[0..]);
    defer convert_float_info.deinit(allocator);
    try expectEqual(
        InfoTypeValue.ConvertFloatMask{ .data = 129 },
        convert_float_info.convert_float,
    );

    @memset(odbc_buf[0..], 0);
    const convert_integer_info = try con.getInfo(allocator, .convert_integer, odbc_buf[0..]);
    defer convert_integer_info.deinit(allocator);
    try expectEqual(
        InfoTypeValue.ConvertIntegerMask{ .data = 129 },
        convert_integer_info.convert_integer,
    );

    @memset(odbc_buf[0..], 0);
    const convert_interval_day_time_info = try con.getInfo(allocator, .convert_interval_day_time, odbc_buf[0..]);
    defer convert_interval_day_time_info.deinit(allocator);
    try expectEqual(
        InfoTypeValue.ConvertIntervalDayTimeMask{ .data = 0 },
        convert_interval_day_time_info.convert_interval_day_time,
    );

    @memset(odbc_buf[0..], 0);
    const convert_interval_year_month_info = try con.getInfo(allocator, .convert_interval_year_month, odbc_buf[0..]);
    defer convert_interval_year_month_info.deinit(allocator);
    try expectEqual(
        InfoTypeValue.ConvertIntervalYearMonthMask{ .data = 0 },
        convert_interval_year_month_info.convert_interval_year_month,
    );

    @memset(odbc_buf[0..], 0);
    const convert_longvarbinary_info = try con.getInfo(allocator, .convert_longvarbinary, odbc_buf[0..]);
    defer convert_longvarbinary_info.deinit(allocator);
    try expectEqual(
        InfoTypeValue.ConvertLongvarbinaryMask{ .data = 0 },
        convert_longvarbinary_info.convert_longvarbinary,
    );

    @memset(odbc_buf[0..], 0);
    const convert_longvarchar_info = try con.getInfo(allocator, .convert_longvarchar, odbc_buf[0..]);
    defer convert_longvarchar_info.deinit(allocator);
    try expectEqual(
        InfoTypeValue.ConvertLongvarcharMask{ .data = 0 },
        convert_longvarchar_info.convert_longvarchar,
    );

    @memset(odbc_buf[0..], 0);
    const convert_numeric_info = try con.getInfo(allocator, .convert_numeric, odbc_buf[0..]);
    defer convert_numeric_info.deinit(allocator);
    try expectEqual(
        InfoTypeValue.ConvertNumericMask{ .data = 129 },
        convert_numeric_info.convert_numeric,
    );

    @memset(odbc_buf[0..], 0);
    const convert_real_info = try con.getInfo(allocator, .convert_real, odbc_buf[0..]);
    defer convert_real_info.deinit(allocator);
    try expectEqual(
        InfoTypeValue.ConvertRealMask{ .data = 0 },
        convert_real_info.convert_real,
    );

    @memset(odbc_buf[0..], 0);
    const convert_smallint_info = try con.getInfo(allocator, .convert_smallint, odbc_buf[0..]);
    defer convert_smallint_info.deinit(allocator);
    try expectEqual(
        InfoTypeValue.ConvertSmallintMask{ .data = 129 },
        convert_smallint_info.convert_smallint,
    );

    @memset(odbc_buf[0..], 0);
    const convert_time_info = try con.getInfo(allocator, .convert_time, odbc_buf[0..]);
    defer convert_time_info.deinit(allocator);
    try expectEqual(
        InfoTypeValue.ConvertTimeMask{ .data = 1 },
        convert_time_info.convert_time,
    );

    @memset(odbc_buf[0..], 0);
    const convert_timestamp_info = try con.getInfo(allocator, .convert_timestamp, odbc_buf[0..]);
    defer convert_timestamp_info.deinit(allocator);
    try expectEqual(
        InfoTypeValue.ConvertTimestampMask{ .data = 1 },
        convert_timestamp_info.convert_timestamp,
    );

    @memset(odbc_buf[0..], 0);
    const convert_tinyint_info = try con.getInfo(allocator, .convert_tinyint, odbc_buf[0..]);
    defer convert_tinyint_info.deinit(allocator);
    try expectEqual(
        InfoTypeValue.ConvertTinyintMask{ .data = 0 },
        convert_tinyint_info.convert_tinyint,
    );

    @memset(odbc_buf[0..], 0);
    const convert_varbinary_info = try con.getInfo(allocator, .convert_varbinary, odbc_buf[0..]);
    defer convert_varbinary_info.deinit(allocator);
    try expectEqual(
        InfoTypeValue.ConvertVarbinaryMask{ .data = 0 },
        convert_varbinary_info.convert_varbinary,
    );

    @memset(odbc_buf[0..], 0);
    const convert_varchar_info = try con.getInfo(allocator, .convert_varchar, odbc_buf[0..]);
    defer convert_varchar_info.deinit(allocator);
    try expectEqual(
        InfoTypeValue.ConvertVarcharMask{ .data = 128 },
        convert_varchar_info.convert_varchar,
    );

    @memset(odbc_buf[0..], 0);
    const convert_functions_info = try con.getInfo(allocator, .convert_functions, odbc_buf[0..]);
    defer convert_functions_info.deinit(allocator);
    try expectEqual(
        InfoTypeValue.ConvertFunctionsMask{ .data = 3 },
        convert_functions_info.convert_functions,
    );

    @memset(odbc_buf[0..], 0);
    const correlation_name_info = try con.getInfo(allocator, .correlation_name, odbc_buf[0..]);
    defer correlation_name_info.deinit(allocator);
    try expectEqual(
        InfoTypeValue.CorrelationName.any,
        correlation_name_info.correlation_name,
    );

    @memset(odbc_buf[0..], 0);
    const create_assertion_info = try con.getInfo(allocator, .create_assertion, odbc_buf[0..]);
    defer create_assertion_info.deinit(allocator);
    try expectEqual(
        InfoTypeValue.CreateAssertionMask{ .data = 0 },
        create_assertion_info.create_assertion,
    );

    @memset(odbc_buf[0..], 0);
    const create_character_set_info = try con.getInfo(allocator, .create_character_set, odbc_buf[0..]);
    defer create_character_set_info.deinit(allocator);
    try expectEqual(
        InfoTypeValue.CreateCharacterSetMask{ .data = 0 },
        create_character_set_info.create_character_set,
    );

    @memset(odbc_buf[0..], 0);
    const create_collation_info = try con.getInfo(allocator, .create_collation, odbc_buf[0..]);
    defer create_collation_info.deinit(allocator);
    try expectEqual(
        InfoTypeValue.CreateCollationMask{ .data = 0 },
        create_collation_info.create_collation,
    );

    @memset(odbc_buf[0..], 0);
    const create_domain_info = try con.getInfo(allocator, .create_domain, odbc_buf[0..]);
    defer create_domain_info.deinit(allocator);
    try expectEqual(
        InfoTypeValue.CreateDomainMask{ .data = 0 },
        create_domain_info.create_domain,
    );

    @memset(odbc_buf[0..], 0);
    const create_schema_info = try con.getInfo(allocator, .create_schema, odbc_buf[0..]);
    defer create_schema_info.deinit(allocator);
    try expectEqual(
        InfoTypeValue.CreateSchemaMask{ .data = 3 },
        create_schema_info.create_schema,
    );

    @memset(odbc_buf[0..], 0);
    const create_table_info = try con.getInfo(allocator, .create_table, odbc_buf[0..]);
    defer create_table_info.deinit(allocator);
    try expectEqual(
        InfoTypeValue.CreateTableMask{ .data = 9729 },
        create_table_info.create_table,
    );

    @memset(odbc_buf[0..], 0);
    const create_translation_info = try con.getInfo(allocator, .create_translation, odbc_buf[0..]);
    defer create_translation_info.deinit(allocator);
    try expectEqual(
        InfoTypeValue.CreateTranslationMask{ .data = 0 },
        create_translation_info.create_translation,
    );

    @memset(odbc_buf[0..], 0);
    const cursor_commit_behavior_info = try con.getInfo(allocator, .cursor_commit_behavior, odbc_buf[0..]);
    defer cursor_commit_behavior_info.deinit(allocator);
    try expectEqual(
        InfoTypeValue.CursorBehavior.preserve,
        cursor_commit_behavior_info.cursor_commit_behavior,
    );

    @memset(odbc_buf[0..], 0);
    const cursor_rollback_behavior_info = try con.getInfo(allocator, .cursor_rollback_behavior, odbc_buf[0..]);
    defer cursor_rollback_behavior_info.deinit(allocator);
    try expectEqual(
        InfoTypeValue.CursorBehavior.close,
        cursor_rollback_behavior_info.cursor_rollback_behavior,
    );

    @memset(odbc_buf[0..], 0);
    const cursor_sensitivity_info = try con.getInfo(allocator, .cursor_sensitivity, odbc_buf[0..]);
    defer cursor_sensitivity_info.deinit(allocator);
    try expectEqual(
        InfoTypeValue.CursorSensitivity.unspecified,
        cursor_sensitivity_info.cursor_sensitivity,
    );

    @memset(odbc_buf[0..], 0);
    const data_source_name_info = try con.getInfo(allocator, .data_source_name, odbc_buf[0..]);
    defer data_source_name_info.deinit(allocator);
    try expectEqualStrings("", data_source_name_info.data_source_name);

    @memset(odbc_buf[0..], 0);
    const data_source_read_only_info = try con.getInfo(allocator, .data_source_read_only, odbc_buf[0..]);
    defer data_source_read_only_info.deinit(allocator);
    try expectEqual(false, data_source_read_only_info.data_source_read_only);

    @memset(odbc_buf[0..], 0);
    const database_name_info = try con.getInfo(allocator, .database_name, odbc_buf[0..]);
    defer database_name_info.deinit(allocator);
    try expectEqualStrings("TESTDB", database_name_info.database_name);

    @memset(odbc_buf[0..], 0);
    const dbms_name_info = try con.getInfo(allocator, .dbms_name, odbc_buf[0..]);
    defer dbms_name_info.deinit(allocator);
    try expectEqualStrings("DB2/LINUXX8664", dbms_name_info.dbms_name);

    @memset(odbc_buf[0..], 0);
    const dbms_ver_info = try con.getInfo(allocator, .dbms_ver, odbc_buf[0..]);
    defer dbms_ver_info.deinit(allocator);
    try expectEqualStrings("11.05.0900", dbms_ver_info.dbms_ver);

    @memset(odbc_buf[0..], 0);
    const ddl_index_info = try con.getInfo(allocator, .ddl_index, odbc_buf[0..]);
    defer ddl_index_info.deinit(allocator);
    try expectEqual(
        InfoTypeValue.DdlIndexMask{ .data = 3 },
        ddl_index_info.ddl_index,
    );

    @memset(odbc_buf[0..], 0);
    const default_txn_isolation_info = try con.getInfo(allocator, .default_txn_isolation, odbc_buf[0..]);
    defer default_txn_isolation_info.deinit(allocator);
    try expectEqual(
        InfoTypeValue.DefaultTxnIsolationMask{ .data = 2 },
        default_txn_isolation_info.default_txn_isolation,
    );

    @memset(odbc_buf[0..], 0);
    const describe_parameter_info = try con.getInfo(allocator, .describe_parameter, odbc_buf[0..]);
    defer describe_parameter_info.deinit(allocator);
    try expectEqual(true, describe_parameter_info.describe_parameter);

    @memset(odbc_buf[0..], 0);
    const driver_hdbc_info = try con.getInfo(allocator, .driver_hdbc, odbc_buf[0..]);
    defer driver_hdbc_info.deinit(allocator);
    try expect(driver_hdbc_info.driver_hdbc > 0);

    @memset(odbc_buf[0..], 0);
    const driver_henv_info = try con.getInfo(allocator, .driver_henv, odbc_buf[0..]);
    defer driver_henv_info.deinit(allocator);
    try expect(driver_henv_info.driver_henv > 0);

    @memset(odbc_buf[0..], 0);
    const driver_hlib_info = try con.getInfo(allocator, .driver_hlib, odbc_buf[0..]);
    defer driver_hlib_info.deinit(allocator);
    try expect(driver_hlib_info.driver_hlib > 0);

    // TODO:
    // - seems to require a statement on the connection
    // @memset(odbc_buf[0..], 0);
    // const driver_hstmt_info = try con.getInfo(allocator, .driver_hstmt, odbc_buf[0..]);
    // defer driver_hstmt_info.deinit(allocator);
    // try expect(driver_hstmt_info.DriverHstmt > 0);

    @memset(odbc_buf[0..], 0);
    const driver_name_info = try con.getInfo(allocator, .driver_name, odbc_buf[0..]);
    defer driver_name_info.deinit(allocator);
    try expectEqualStrings("libdb2.a", driver_name_info.driver_name);

    @memset(odbc_buf[0..], 0);
    const driver_odbc_ver = try con.getInfo(allocator, .driver_odbc_ver, odbc_buf[0..]);
    defer driver_odbc_ver.deinit(allocator);
    try expectEqualStrings("03.51", driver_odbc_ver.driver_odbc_ver);

    @memset(odbc_buf[0..], 0);
    const driver_ver_info = try con.getInfo(allocator, .driver_ver, odbc_buf[0..]);
    defer driver_ver_info.deinit(allocator);
    try expectEqualStrings("11.05.0900", driver_ver_info.driver_ver);

    @memset(odbc_buf[0..], 0);
    const drop_assertion_info = try con.getInfo(allocator, .drop_assertion, odbc_buf[0..]);
    defer drop_assertion_info.deinit(allocator);
    try expectEqual(
        InfoTypeValue.DropAssertionMask{ .data = 0 },
        drop_assertion_info.drop_assertion,
    );

    @memset(odbc_buf[0..], 0);
    const drop_character_set_info = try con.getInfo(allocator, .drop_character_set, odbc_buf[0..]);
    defer drop_character_set_info.deinit(allocator);
    try expectEqual(
        InfoTypeValue.DropCharacterSetMask{ .data = 0 },
        drop_character_set_info.drop_character_set,
    );

    @memset(odbc_buf[0..], 0);
    const drop_collation_info = try con.getInfo(allocator, .drop_collation, odbc_buf[0..]);
    defer drop_collation_info.deinit(allocator);
    try expectEqual(
        InfoTypeValue.DropCollationMask{ .data = 0 },
        drop_collation_info.drop_collation,
    );

    @memset(odbc_buf[0..], 0);
    const drop_domain_info = try con.getInfo(allocator, .drop_domain, odbc_buf[0..]);
    defer drop_domain_info.deinit(allocator);
    try expectEqual(
        InfoTypeValue.DropDomainMask{ .data = 0 },
        drop_domain_info.drop_domain,
    );

    @memset(odbc_buf[0..], 0);
    const drop_schema_info = try con.getInfo(allocator, .drop_schema, odbc_buf[0..]);
    defer drop_schema_info.deinit(allocator);
    try expectEqual(
        InfoTypeValue.DropSchemaMask{ .data = 3 },
        drop_schema_info.drop_schema,
    );

    @memset(odbc_buf[0..], 0);
    const drop_table_info = try con.getInfo(allocator, .drop_table, odbc_buf[0..]);
    defer drop_table_info.deinit(allocator);
    try expectEqual(
        InfoTypeValue.DropTableMask{ .data = 1 },
        drop_table_info.drop_table,
    );

    @memset(odbc_buf[0..], 0);
    const drop_translation_info = try con.getInfo(allocator, .drop_translation, odbc_buf[0..]);
    defer drop_translation_info.deinit(allocator);
    try expectEqual(
        InfoTypeValue.DropTranslationMask{ .data = 0 },
        drop_translation_info.drop_translation,
    );

    @memset(odbc_buf[0..], 0);
    const drop_view_info = try con.getInfo(allocator, .drop_view, odbc_buf[0..]);
    defer drop_view_info.deinit(allocator);
    try expectEqual(
        InfoTypeValue.DropViewMask{ .data = 1 },
        drop_view_info.drop_view,
    );

    @memset(odbc_buf[0..], 0);
    const dynamic_cursor_attributes_1 = try con.getInfo(allocator, .dynamic_cursor_attributes1, odbc_buf[0..]);
    defer dynamic_cursor_attributes_1.deinit(allocator);
    try expectEqual(
        InfoTypeValue.DynamicCursorAttributes1Mask{ .data = 0 },
        dynamic_cursor_attributes_1.dynamic_cursor_attributes1,
    );

    @memset(odbc_buf[0..], 0);
    const dynamic_cursor_attributes_2 = try con.getInfo(allocator, .dynamic_cursor_attributes2, odbc_buf[0..]);
    defer dynamic_cursor_attributes_2.deinit(allocator);
    try expectEqual(
        InfoTypeValue.DynamicCursorAttributes2Mask{ .data = 0 },
        dynamic_cursor_attributes_2.dynamic_cursor_attributes2,
    );

    @memset(odbc_buf[0..], 0);
    const expressions_in_orderby_info = try con.getInfo(allocator, .expressions_in_orderby, odbc_buf[0..]);
    defer expressions_in_orderby_info.deinit(allocator);
    try expectEqual(true, expressions_in_orderby_info.expressions_in_orderby);

    @memset(odbc_buf[0..], 0);
    const fetch_direction_info = try con.getInfo(allocator, .fetch_direction, odbc_buf[0..]);
    defer fetch_direction_info.deinit(allocator);
    try expectEqual(
        InfoTypeValue.FetchDirectionMask{ .data = 255 },
        fetch_direction_info.fetch_direction,
    );

    @memset(odbc_buf[0..], 0);
    const forward_only_cursor_attributes_1 = try con.getInfo(allocator, .forward_only_cursor_attributes1, odbc_buf[0..]);
    defer forward_only_cursor_attributes_1.deinit(allocator);
    try expectEqual(
        InfoTypeValue.ForwardOnlyCursorAttributes1Mask{ .data = 57345 },
        forward_only_cursor_attributes_1.forward_only_cursor_attributes1,
    );

    @memset(odbc_buf[0..], 0);
    const forward_only_cursor_attributes_2 = try con.getInfo(allocator, .forward_only_cursor_attributes2, odbc_buf[0..]);
    defer forward_only_cursor_attributes_2.deinit(allocator);
    try expectEqual(
        InfoTypeValue.ForwardOnlyCursorAttributes2Mask{ .data = 2179 },
        forward_only_cursor_attributes_2.forward_only_cursor_attributes2,
    );

    @memset(odbc_buf[0..], 0);
    const getdata_extensions_info = try con.getInfo(allocator, .getdata_extensions, odbc_buf[0..]);
    defer getdata_extensions_info.deinit(allocator);
    try expectEqual(
        InfoTypeValue.GetdataExtensionsMask{ .data = 7 },
        getdata_extensions_info.getdata_extensions,
    );

    @memset(odbc_buf[0..], 0);
    const group_by_info = try con.getInfo(allocator, .group_by, odbc_buf[0..]);
    defer group_by_info.deinit(allocator);
    try expectEqual(
        InfoTypeValue.GroupBy.group_by_contains_select,
        group_by_info.group_by,
    );

    @memset(odbc_buf[0..], 0);
    const identifier_case_info = try con.getInfo(allocator, .identifier_case, odbc_buf[0..]);
    defer identifier_case_info.deinit(allocator);
    try expectEqual(
        InfoTypeValue.IdentifierCase.upper,
        identifier_case_info.identifier_case,
    );

    @memset(odbc_buf[0..], 0);
    const identifier_quote_char_info = try con.getInfo(allocator, .identifier_quote_char, odbc_buf[0..]);
    defer identifier_quote_char_info.deinit(allocator);
    try expectEqualStrings(
        "\"",
        identifier_quote_char_info.identifier_quote_char,
    );

    @memset(odbc_buf[0..], 0);
    const info_schema_views_info = try con.getInfo(allocator, .info_schema_views, odbc_buf[0..]);
    defer info_schema_views_info.deinit(allocator);
    try expectEqual(
        InfoTypeValue.InfoSchemaViewsMask{ .data = 0 },
        info_schema_views_info.info_schema_views,
    );

    @memset(odbc_buf[0..], 0);
    const insert_statement_info = try con.getInfo(allocator, .insert_statement, odbc_buf[0..]);
    defer insert_statement_info.deinit(allocator);
    try expectEqual(
        InfoTypeValue.InsertStatementMask{ .data = 7 },
        insert_statement_info.insert_statement,
    );

    @memset(odbc_buf[0..], 0);
    const integrity_info = try con.getInfo(allocator, .integrity, odbc_buf[0..]);
    defer integrity_info.deinit(allocator);
    try expectEqual(true, integrity_info.integrity);

    @memset(odbc_buf[0..], 0);
    const keyset_cursor_attributes1_info = try con.getInfo(allocator, .keyset_cursor_attributes1, odbc_buf[0..]);
    defer keyset_cursor_attributes1_info.deinit(allocator);
    try expectEqual(
        InfoTypeValue.KeysetCursorAttributes1Mask{ .data = 990799 },
        keyset_cursor_attributes1_info.keyset_cursor_attributes1,
    );

    @memset(odbc_buf[0..], 0);
    const keyset_cursor_attributes2_info = try con.getInfo(allocator, .keyset_cursor_attributes2, odbc_buf[0..]);
    defer keyset_cursor_attributes2_info.deinit(allocator);
    try expectEqual(
        InfoTypeValue.KeysetCursorAttributes2Mask{ .data = 16395 },
        keyset_cursor_attributes2_info.keyset_cursor_attributes2,
    );

    @memset(odbc_buf[0..], 0);
    const keywords_info = try con.getInfo(allocator, .keywords, odbc_buf[0..]);
    defer keywords_info.deinit(allocator);
    try expectEqualStrings(
        "AFTER,ALIAS,ALLOW,APPLICATION,ASSOCIATE,ASUTIME,AUDIT,AUX,AUXILIARY,BEFORE,BINARY,BUFFERPOOL,CACHE,CALL,CALLED,CAPTURE,CARDINALITY,CCSID,CLUSTER,COLLECTION,COLLID,COMMENT,CONCAT,CONDITION,CONTAINS,COUNT_BIG,CURRENT_LC_CTYPE,CURRENT_PATH,CURRENT_SERVER,CURRENT_TIMEZONE,CYCLE,DATA,DATABASE,DAYS,DB2GENERAL,DB2GENRL,DB2SQL,DBINFO,DEFAULTS,DEFINITION,DETERMINISTIC,DISALLOW,DO,DSNHATTR,DSSIZE,DYNAMIC,EACH,EDITPROC,ELSEIF,ENCODING,END-EXEC1,ERASE,EXCLUDING,EXIT,FENCED,FIELDPROC,FILE,FINAL,FREE,FUNCTION,GENERAL,GENERATED,GRAPHIC,HANDLER,HOLD,HOURS,IF,INCLUDING,INCREMENT,INHERIT,INOUT,INTEGRITY,ISOBID,ITERATE,JAR,JAVA,LABEL,LC_CTYPE,LEAVE,LINKTYPE,LOCALE,LOCATOR,LOCATORS,LOCK,LOCKMAX,LOCKSIZE,LONG,LOOP,MAXVALUE,MICROSECOND,MICROSECONDS,MINUTES,MINVALUE,MODE,MODIFIES,MONTHS,NEW,NEW_TABLE,NOCACHE,NOCYCLE,NODENAME,NODENUMBER,NOMAXVALUE,NOMINVALUE,NOORDER,NULLS,NUMPARTS,OBID,OLD,OLD_TABLE,OPTIMIZATION,OPTIMIZE,OUT,OVERRIDING,PACKAGE,PARAMETER,PART,PARTITION,PATH,PIECESIZE,PLAN,PRIQTY,PROGRAM,PSID,QUERYNO,READS,RECOVERY,REFERENCING,RELEASE,RENAME,REPEAT,RESET,RESIGNAL,RESTART,RESULT,RESULT_SET_LOCATOR,RETURN,RETURNS,ROUTINE,ROW,RRN,RUN,SAVEPOINT,SCRATCHPAD,SECONDS,SECQTY,SECURITY,SENSITIVE,SIGNAL,SIMPLE,SOURCE,SPECIFIC,SQLID,STANDARD,START,STATIC,STAY,STOGROUP,STORES,STYLE,SUBPAGES,SYNONYM,SYSFUN,SYSIBM,SYSPROC,SYSTEM,TABLESPACE,TRIGGER,TYPE,UNDO,UNTIL,VALIDPROC,VARIABLE,VARIANT,VCAT,VOLUMES,WHILE,WLM,YEARS",
        keywords_info.keywords,
    );

    @memset(odbc_buf[0..], 0);
    const like_escape_clause_info = try con.getInfo(allocator, .like_escape_clause, odbc_buf[0..]);
    defer like_escape_clause_info.deinit(allocator);
    try expectEqual(true, like_escape_clause_info.like_escape_clause);

    @memset(odbc_buf[0..], 0);
    const lock_types_info = try con.getInfo(allocator, .lock_types, odbc_buf[0..]);
    defer lock_types_info.deinit(allocator);
    try expectEqual(
        InfoTypeValue.LockTypesMask{ .data = 0 },
        lock_types_info.lock_types,
    );

    @memset(odbc_buf[0..], 0);
    const max_async_concurrent_statements_info = try con.getInfo(allocator, .max_async_concurrent_statements, odbc_buf[0..]);
    defer max_async_concurrent_statements_info.deinit(allocator);
    try expectEqual(1, max_async_concurrent_statements_info.max_async_concurrent_statements);

    @memset(odbc_buf[0..], 0);
    const max_binary_literal_len_info = try con.getInfo(allocator, .max_binary_literal_len, odbc_buf[0..]);
    defer max_binary_literal_len_info.deinit(allocator);
    try expectEqual(4000, max_binary_literal_len_info.max_binary_literal_len);

    @memset(odbc_buf[0..], 0);
    const max_catalog_name_len_info = try con.getInfo(allocator, .max_catalog_name_len, odbc_buf[0..]);
    defer max_catalog_name_len_info.deinit(allocator);
    try expectEqual(0, max_catalog_name_len_info.max_catalog_name_len);

    @memset(odbc_buf[0..], 0);
    const max_char_literal_len_info = try con.getInfo(allocator, .max_char_literal_len, odbc_buf[0..]);
    defer max_char_literal_len_info.deinit(allocator);
    try expectEqual(32672, max_char_literal_len_info.max_char_literal_len);

    @memset(odbc_buf[0..], 0);
    const max_column_name_len_info = try con.getInfo(allocator, .max_column_name_len, odbc_buf[0..]);
    defer max_column_name_len_info.deinit(allocator);
    try expectEqual(128, max_column_name_len_info.max_column_name_len);

    @memset(odbc_buf[0..], 0);
    const max_columns_in_group_by_info = try con.getInfo(allocator, .max_columns_in_group_by, odbc_buf[0..]);
    defer max_columns_in_group_by_info.deinit(allocator);
    try expectEqual(1012, max_columns_in_group_by_info.max_columns_in_group_by);

    @memset(odbc_buf[0..], 0);
    const max_columns_in_index_info = try con.getInfo(allocator, .max_columns_in_index, odbc_buf[0..]);
    defer max_columns_in_index_info.deinit(allocator);
    try expectEqual(16, max_columns_in_index_info.max_columns_in_index);

    @memset(odbc_buf[0..], 0);
    const max_columns_in_order_by_info = try con.getInfo(allocator, .max_columns_in_order_by, odbc_buf[0..]);
    defer max_columns_in_order_by_info.deinit(allocator);
    try expectEqual(1012, max_columns_in_order_by_info.max_columns_in_order_by);

    @memset(odbc_buf[0..], 0);
    const max_columns_in_select_info = try con.getInfo(allocator, .max_columns_in_select, odbc_buf[0..]);
    defer max_columns_in_select_info.deinit(allocator);
    try expectEqual(1012, max_columns_in_select_info.max_columns_in_select);

    @memset(odbc_buf[0..], 0);
    const max_columns_in_table_info = try con.getInfo(allocator, .max_columns_in_table, odbc_buf[0..]);
    defer max_columns_in_table_info.deinit(allocator);
    try expectEqual(1012, max_columns_in_table_info.max_columns_in_table);

    @memset(odbc_buf[0..], 0);
    const max_concurrent_activities_info = try con.getInfo(allocator, .max_concurrent_activities, odbc_buf[0..]);
    defer max_concurrent_activities_info.deinit(allocator);
    try expectEqual(0, max_concurrent_activities_info.max_concurrent_activities);

    @memset(odbc_buf[0..], 0);
    const max_cursor_name_len_info = try con.getInfo(allocator, .max_cursor_name_len, odbc_buf[0..]);
    defer max_cursor_name_len_info.deinit(allocator);
    try expectEqual(128, max_cursor_name_len_info.max_cursor_name_len);

    @memset(odbc_buf[0..], 0);
    const max_driver_connections_info = try con.getInfo(allocator, .max_driver_connections, odbc_buf[0..]);
    defer max_driver_connections_info.deinit(allocator);
    try expectEqual(0, max_driver_connections_info.max_driver_connections);

    @memset(odbc_buf[0..], 0);
    const max_identifier_len_info = try con.getInfo(allocator, .max_identifier_len, odbc_buf[0..]);
    defer max_identifier_len_info.deinit(allocator);
    try expectEqual(128, max_identifier_len_info.max_identifier_len);

    @memset(odbc_buf[0..], 0);
    const max_index_size_info = try con.getInfo(allocator, .max_index_size, odbc_buf[0..]);
    defer max_index_size_info.deinit(allocator);
    try expectEqual(1024, max_index_size_info.max_index_size);

    @memset(odbc_buf[0..], 0);
    const max_procedure_name_len_info = try con.getInfo(allocator, .max_procedure_name_len, odbc_buf[0..]);
    defer max_procedure_name_len_info.deinit(allocator);
    try expectEqual(128, max_procedure_name_len_info.max_procedure_name_len);

    @memset(odbc_buf[0..], 0);
    const max_row_size_info = try con.getInfo(allocator, .max_row_size, odbc_buf[0..]);
    defer max_row_size_info.deinit(allocator);
    try expectEqual(32677, max_row_size_info.max_row_size);

    @memset(odbc_buf[0..], 0);
    const max_row_size_includes_long_info = try con.getInfo(allocator, .max_row_size_includes_long, odbc_buf[0..]);
    defer max_row_size_includes_long_info.deinit(allocator);
    try expectEqual(false, max_row_size_includes_long_info.max_row_size_includes_long);

    @memset(odbc_buf[0..], 0);
    const max_schema_name_len_info = try con.getInfo(allocator, .max_schema_name_len, odbc_buf[0..]);
    defer max_schema_name_len_info.deinit(allocator);
    try expectEqual(128, max_schema_name_len_info.max_schema_name_len);

    @memset(odbc_buf[0..], 0);
    const max_statement_len_info = try con.getInfo(allocator, .max_statement_len, odbc_buf[0..]);
    defer max_statement_len_info.deinit(allocator);
    try expectEqual(2097152, max_statement_len_info.max_statement_len);

    @memset(odbc_buf[0..], 0);
    const max_table_name_len_info = try con.getInfo(allocator, .max_table_name_len, odbc_buf[0..]);
    defer max_table_name_len_info.deinit(allocator);
    try expectEqual(128, max_table_name_len_info.max_table_name_len);

    @memset(odbc_buf[0..], 0);
    const max_tables_in_select_info = try con.getInfo(allocator, .max_tables_in_select, odbc_buf[0..]);
    defer max_tables_in_select_info.deinit(allocator);
    try expectEqual(0, max_tables_in_select_info.max_tables_in_select);

    @memset(odbc_buf[0..], 0);
    const max_user_name_len_info = try con.getInfo(allocator, .max_user_name_len, odbc_buf[0..]);
    defer max_user_name_len_info.deinit(allocator);
    try expectEqual(8, max_user_name_len_info.max_user_name_len);

    @memset(odbc_buf[0..], 0);
    const mult_result_sets_info = try con.getInfo(allocator, .mult_result_sets, odbc_buf[0..]);
    defer mult_result_sets_info.deinit(allocator);
    try expectEqual(true, mult_result_sets_info.mult_result_sets);

    @memset(odbc_buf[0..], 0);
    const multiple_active_txn_info = try con.getInfo(allocator, .multiple_active_txn, odbc_buf[0..]);
    defer multiple_active_txn_info.deinit(allocator);
    try expectEqual(true, multiple_active_txn_info.multiple_active_txn);

    @memset(odbc_buf[0..], 0);
    const need_long_data_len_info = try con.getInfo(allocator, .need_long_data_len, odbc_buf[0..]);
    defer need_long_data_len_info.deinit(allocator);
    try expectEqual(false, need_long_data_len_info.need_long_data_len);

    @memset(odbc_buf[0..], 0);
    const non_nullable_columns_info = try con.getInfo(allocator, .non_nullable_columns, odbc_buf[0..]);
    defer non_nullable_columns_info.deinit(allocator);
    try expectEqual(
        InfoTypeValue.NonNullableColumns.non_null,
        non_nullable_columns_info.non_nullable_columns,
    );

    @memset(odbc_buf[0..], 0);
    const null_collation_info = try con.getInfo(allocator, .null_collation, odbc_buf[0..]);
    defer null_collation_info.deinit(allocator);
    try expectEqual(
        InfoTypeValue.NullCollation.high,
        null_collation_info.null_collation,
    );

    @memset(odbc_buf[0..], 0);
    const numeric_functions_info = try con.getInfo(allocator, .numeric_functions, odbc_buf[0..]);
    defer numeric_functions_info.deinit(allocator);
    try expectEqual(
        InfoTypeValue.NumericFunctionsMask{ .data = 16777215 },
        numeric_functions_info.numeric_functions,
    );

    @memset(odbc_buf[0..], 0);
    const odbc_api_conformance_info = try con.getInfo(allocator, .odbc_api_conformance, odbc_buf[0..]);
    defer odbc_api_conformance_info.deinit(allocator);
    try expectEqual(
        InfoTypeValue.OdbcApiConformance.level2,
        odbc_api_conformance_info.odbc_api_conformance,
    );

    @memset(odbc_buf[0..], 0);
    const odbc_sag_cli_conformance_info = try con.getInfo(allocator, .odbc_sag_cli_conformance, odbc_buf[0..]);
    defer odbc_sag_cli_conformance_info.deinit(allocator);
    try expectEqual(
        InfoTypeValue.OdbcSagCliConformance.compliant,
        odbc_sag_cli_conformance_info.odbc_sag_cli_conformance,
    );

    @memset(odbc_buf[0..], 0);
    const odbc_sql_conformance_info = try con.getInfo(allocator, .odbc_sql_conformance, odbc_buf[0..]);
    defer odbc_sql_conformance_info.deinit(allocator);
    try expectEqual(
        InfoTypeValue.OdbcSqlConformance.extended,
        odbc_sql_conformance_info.odbc_sql_conformance,
    );

    @memset(odbc_buf[0..], 0);
    const odbc_ver_info = try con.getInfo(allocator, .odbc_ver, odbc_buf[0..]);
    defer odbc_ver_info.deinit(allocator);
    try expectEqualStrings("03.52", odbc_ver_info.odbc_ver);

    @memset(odbc_buf[0..], 0);
    const oj_capabilities_info = try con.getInfo(allocator, .oj_capabilities, odbc_buf[0..]);
    defer oj_capabilities_info.deinit(allocator);
    try expectEqual(
        InfoTypeValue.OjCapabilitiesMask{ .data = 127 },
        oj_capabilities_info.oj_capabilities,
    );

    @memset(odbc_buf[0..], 0);
    const order_by_columns_in_select_info = try con.getInfo(allocator, .order_by_columns_in_select, odbc_buf[0..]);
    defer order_by_columns_in_select_info.deinit(allocator);
    try expectEqual(false, order_by_columns_in_select_info.order_by_columns_in_select);

    @memset(odbc_buf[0..], 0);
    const outer_joins_info = try con.getInfo(allocator, .outer_joins, odbc_buf[0..]);
    defer outer_joins_info.deinit(allocator);
    try expectEqual(true, outer_joins_info.outer_joins);

    @memset(odbc_buf[0..], 0);
    const owner_term_info = try con.getInfo(allocator, .owner_term, odbc_buf[0..]);
    defer owner_term_info.deinit(allocator);
    try expectEqualStrings("schema", owner_term_info.owner_term);

    @memset(odbc_buf[0..], 0);
    const param_array_row_counts_info = try con.getInfo(allocator, .param_array_row_counts, odbc_buf[0..]);
    defer param_array_row_counts_info.deinit(allocator);
    try expectEqual(
        InfoTypeValue.ParamArrayRowCounts.no_batch,
        param_array_row_counts_info.param_array_row_counts,
    );

    @memset(odbc_buf[0..], 0);
    const param_array_selects_info = try con.getInfo(allocator, .param_array_selects, odbc_buf[0..]);
    defer param_array_selects_info.deinit(allocator);
    try expectEqual(
        InfoTypeValue.ParamArraySelects.batch,
        param_array_selects_info.param_array_selects,
    );

    @memset(odbc_buf[0..], 0);
    const pos_operations_info = try con.getInfo(allocator, .pos_operations, odbc_buf[0..]);
    defer pos_operations_info.deinit(allocator);
    try expectEqual(
        InfoTypeValue.PosOperationsMask{ .data = 31 },
        pos_operations_info.pos_operations,
    );

    @memset(odbc_buf[0..], 0);
    const positioned_statements_info = try con.getInfo(allocator, .positioned_statements, odbc_buf[0..]);
    defer positioned_statements_info.deinit(allocator);
    try expectEqual(
        InfoTypeValue.PositionedStatementsMask{ .data = 7 },
        positioned_statements_info.positioned_statements,
    );

    @memset(odbc_buf[0..], 0);
    const procedure_term_info = try con.getInfo(allocator, .procedure_term, odbc_buf[0..]);
    defer procedure_term_info.deinit(allocator);
    try expectEqualStrings("stored procedure", procedure_term_info.procedure_term);

    @memset(odbc_buf[0..], 0);
    const procedures_info = try con.getInfo(allocator, .procedures, odbc_buf[0..]);
    defer procedures_info.deinit(allocator);
    try expectEqual(true, procedures_info.procedures);

    @memset(odbc_buf[0..], 0);
    const quoted_identifier_case_info = try con.getInfo(allocator, .quoted_identifier_case, odbc_buf[0..]);
    defer quoted_identifier_case_info.deinit(allocator);
    try expectEqual(
        InfoTypeValue.QuotedIdentifierCase.sensitive,
        quoted_identifier_case_info.quoted_identifier_case,
    );

    @memset(odbc_buf[0..], 0);
    const row_updates_info = try con.getInfo(allocator, .row_updates, odbc_buf[0..]);
    defer row_updates_info.deinit(allocator);
    try expectEqual(false, row_updates_info.row_updates);

    @memset(odbc_buf[0..], 0);
    const schema_usage_info = try con.getInfo(allocator, .schema_usage, odbc_buf[0..]);
    defer schema_usage_info.deinit(allocator);
    try expectEqual(
        InfoTypeValue.SchemaUsageMask{ .data = 31 },
        schema_usage_info.schema_usage,
    );

    @memset(odbc_buf[0..], 0);
    const scroll_concurrency_info = try con.getInfo(allocator, .scroll_concurrency, odbc_buf[0..]);
    defer scroll_concurrency_info.deinit(allocator);
    try expectEqual(
        InfoTypeValue.ScrollConcurrencyMask{ .data = 11 },
        scroll_concurrency_info.scroll_concurrency,
    );

    @memset(odbc_buf[0..], 0);
    const scroll_options_info = try con.getInfo(allocator, .scroll_options, odbc_buf[0..]);
    defer scroll_options_info.deinit(allocator);
    try expectEqual(
        InfoTypeValue.ScrollOptionsMask{ .data = 19 },
        scroll_options_info.scroll_options,
    );

    @memset(odbc_buf[0..], 0);
    const search_pattern_escape_info = try con.getInfo(allocator, .search_pattern_escape, odbc_buf[0..]);
    defer search_pattern_escape_info.deinit(allocator);
    try expectEqualStrings("\\", search_pattern_escape_info.search_pattern_escape);

    @memset(odbc_buf[0..], 0);
    const server_name_info = try con.getInfo(allocator, .server_name, odbc_buf[0..]);
    defer server_name_info.deinit(allocator);
    try expectEqualStrings("DB2", server_name_info.server_name);

    @memset(odbc_buf[0..], 0);
    const special_characters_info = try con.getInfo(allocator, .special_characters, odbc_buf[0..]);
    defer special_characters_info.deinit(allocator);
    try expectEqualStrings("@#", special_characters_info.special_characters);

    @memset(odbc_buf[0..], 0);
    const sql92_predicates_info = try con.getInfo(allocator, .sql92_predicates, odbc_buf[0..]);
    defer sql92_predicates_info.deinit(allocator);
    try expectEqual(
        InfoTypeValue.Sql92PredicatesMask{ .data = 15879 },
        sql92_predicates_info.sql92_predicates,
    );

    @memset(odbc_buf[0..], 0);
    const sql92_value_expressions_info = try con.getInfo(allocator, .sql92_value_expressions, odbc_buf[0..]);
    defer sql92_value_expressions_info.deinit(allocator);
    try expectEqual(
        InfoTypeValue.Sql92ValueExpressionsMask{ .data = 15 },
        sql92_value_expressions_info.sql92_value_expressions,
    );

    @memset(odbc_buf[0..], 0);
    const static_cursor_attributes_1_info = try con.getInfo(allocator, .static_cursor_attributes1, odbc_buf[0..]);
    defer static_cursor_attributes_1_info.deinit(allocator);
    try expectEqual(
        InfoTypeValue.StaticCursorAttributes1Mask{ .data = 15 },
        static_cursor_attributes_1_info.static_cursor_attributes1,
    );

    @memset(odbc_buf[0..], 0);
    const static_cursor_attributes_2_info = try con.getInfo(allocator, .static_cursor_attributes2, odbc_buf[0..]);
    defer static_cursor_attributes_2_info.deinit(allocator);
    try expectEqual(
        InfoTypeValue.StaticCursorAttributes2Mask{ .data = 131 },
        static_cursor_attributes_2_info.static_cursor_attributes2,
    );

    @memset(odbc_buf[0..], 0);
    const static_sensitivity_info = try con.getInfo(allocator, .static_sensitivity, odbc_buf[0..]);
    defer static_sensitivity_info.deinit(allocator);
    try expectEqual(
        InfoTypeValue.StaticSensitivityMask{ .data = 0 },
        static_sensitivity_info.static_sensitivity,
    );

    @memset(odbc_buf[0..], 0);
    const string_functions_info = try con.getInfo(allocator, .string_functions, odbc_buf[0..]);
    defer string_functions_info.deinit(allocator);
    try expectEqual(
        InfoTypeValue.StringFunctionsMask{ .data = 524287 },
        string_functions_info.string_functions,
    );

    @memset(odbc_buf[0..], 0);
    const subqueries_info = try con.getInfo(allocator, .subqueries, odbc_buf[0..]);
    defer subqueries_info.deinit(allocator);
    try expectEqual(
        InfoTypeValue.SubqueriesMask{ .data = 31 },
        subqueries_info.subqueries,
    );

    @memset(odbc_buf[0..], 0);
    const system_functions_info = try con.getInfo(allocator, .system_functions, odbc_buf[0..]);
    defer system_functions_info.deinit(allocator);
    try expectEqual(
        InfoTypeValue.SystemFunctionsMask{ .data = 7 },
        system_functions_info.system_functions,
    );

    @memset(odbc_buf[0..], 0);
    const table_term_info = try con.getInfo(allocator, .table_term, odbc_buf[0..]);
    defer table_term_info.deinit(allocator);
    try expectEqualStrings("table", table_term_info.table_term);

    @memset(odbc_buf[0..], 0);
    const timedate_add_intervals_info = try con.getInfo(allocator, .timedate_add_intervals, odbc_buf[0..]);
    defer timedate_add_intervals_info.deinit(allocator);
    try expectEqual(
        InfoTypeValue.TimedateAddIntervalsMask{ .data = 511 },
        timedate_add_intervals_info.timedate_add_intervals,
    );

    @memset(odbc_buf[0..], 0);
    const timedate_diff_intervals_info = try con.getInfo(allocator, .timedate_diff_intervals, odbc_buf[0..]);
    defer timedate_diff_intervals_info.deinit(allocator);
    try expectEqual(
        InfoTypeValue.TimedateDiffIntervalsMask{ .data = 511 },
        timedate_diff_intervals_info.timedate_diff_intervals,
    );

    @memset(odbc_buf[0..], 0);
    const timedate_functions_info = try con.getInfo(allocator, .timedate_functions, odbc_buf[0..]);
    defer timedate_functions_info.deinit(allocator);
    try expectEqual(
        InfoTypeValue.TimedateFunctionsMask{ .data = 131071 },
        timedate_functions_info.timedate_functions,
    );

    @memset(odbc_buf[0..], 0);
    const txn_capable_info = try con.getInfo(allocator, .txn_capable, odbc_buf[0..]);
    defer txn_capable_info.deinit(allocator);
    try expectEqual(
        InfoTypeValue.TxnCapable.all,
        txn_capable_info.txn_capable,
    );

    @memset(odbc_buf[0..], 0);
    const txn_isolation_option_info = try con.getInfo(allocator, .txn_isolation_option, odbc_buf[0..]);
    defer txn_isolation_option_info.deinit(allocator);
    try expectEqual(
        InfoTypeValue.TxnIsolationOptionMask{ .data = 15 },
        txn_isolation_option_info.txn_isolation_option,
    );

    @memset(odbc_buf[0..], 0);
    const union_info = try con.getInfo(allocator, .@"union", odbc_buf[0..]);
    defer union_info.deinit(allocator);
    try expectEqual(
        InfoTypeValue.UnionMask{ .data = 3 },
        union_info.@"union",
    );

    @memset(odbc_buf[0..], 0);
    const user_name_info = try con.getInfo(allocator, .user_name, odbc_buf[0..]);
    defer user_name_info.deinit(allocator);
    try expectEqualStrings("db2inst1", user_name_info.user_name);

    @memset(odbc_buf[0..], 0);
    const xopen_cli_year_info = try con.getInfo(allocator, .xopen_cli_year, odbc_buf[0..]);
    defer xopen_cli_year_info.deinit(allocator);
    try expectEqualStrings("1995", xopen_cli_year_info.xopen_cli_year);
}
