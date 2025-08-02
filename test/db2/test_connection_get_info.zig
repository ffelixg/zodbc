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
        env_con.con.deinit() catch unreachable;
        env_con.env.deinit() catch unreachable;
    }
    const con = env_con.con;
    const con_str = try zodbc.testing.db2ConnectionString(allocator);
    defer allocator.free(con_str);
    try con.connectWithString(con_str);

    const accessible_procedures_info = try con.getInfo(.accessible_procedures);
    try expectEqual(false, accessible_procedures_info.accessible_procedures);

    const accessible_tables_info = try con.getInfo(.accessible_tables);
    try expectEqual(false, accessible_tables_info.accessible_tables);

    const active_environments_info = try con.getInfo(.active_environments);
    try expectEqual(1, active_environments_info.active_environments);

    const aggregate_functions_info = try con.getInfo(.aggregate_functions);
    try expectEqual(64, aggregate_functions_info.aggregate_functions);

    const alter_domain_info = try con.getInfo(.alter_domain);
    try expectEqual(0, alter_domain_info.alter_domain);

    const alter_table_info = try con.getInfo(.alter_table);
    try expectEqual(61545, alter_table_info.alter_table);

    const batch_row_count_info = try con.getInfo(.batch_row_count);
    try expectEqual(4, batch_row_count_info.batch_row_count);

    const batch_support_info = try con.getInfo(.batch_support);
    try expectEqual(7, batch_support_info.batch_support);

    const bookmark_persistence_info = try con.getInfo(.bookmark_persistence);
    try expectEqual(90, bookmark_persistence_info.bookmark_persistence);

    const catalog_location_info = try con.getInfo(.catalog_location);
    try expectEqual(0, catalog_location_info.catalog_location);

    const catalog_name_info = try con.getInfo(.catalog_name);
    try expectEqual(false, catalog_name_info.catalog_name);

    const catalog_name_separator_info = try con.getInfoString(allocator, .catalog_name_separator);
    defer allocator.free(catalog_name_separator_info);
    try expectEqualStrings(".", catalog_name_separator_info);

    const catalog_term_info = try con.getInfoString(allocator, .catalog_term);
    defer allocator.free(catalog_term_info);
    try expectEqualStrings("", catalog_term_info);

    const catalog_usage_info = try con.getInfo(.catalog_usage);
    try expectEqual(0, catalog_usage_info.catalog_usage);

    const collation_seq_info = try con.getInfoString(allocator, .collation_seq);
    defer allocator.free(collation_seq_info);
    try expectEqualStrings("", collation_seq_info);

    const column_alias_info = try con.getInfo(.column_alias);
    try expectEqual(true, column_alias_info.column_alias);

    const concat_null_behavior_info = try con.getInfo(.concat_null_behavior);
    try expectEqual(
        InfoTypeValue.ConcatNullBehavior.null,
        concat_null_behavior_info.concat_null_behavior,
    );

    const convert_bigint_info = try con.getInfo(.convert_bigint);
    try expectEqual(0, convert_bigint_info.convert_bigint);

    const convert_binary_info = try con.getInfo(.convert_binary);
    try expectEqual(0, convert_binary_info.convert_binary);

    const convert_bit_info = try con.getInfo(.convert_bit);
    try expectEqual(0, convert_bit_info.convert_bit);

    const convert_char_info = try con.getInfo(.convert_char);
    try expectEqual(129, convert_char_info.convert_char);

    const convert_date_info = try con.getInfo(.convert_date);
    try expectEqual(1, convert_date_info.convert_date);

    const convert_decimal_info = try con.getInfo(.convert_decimal);
    try expectEqual(129, convert_decimal_info.convert_decimal);

    const convert_double_info = try con.getInfo(.convert_double);
    try expectEqual(129, convert_double_info.convert_double);

    const convert_float_info = try con.getInfo(.convert_float);
    try expectEqual(129, convert_float_info.convert_float);

    const convert_integer_info = try con.getInfo(.convert_integer);
    try expectEqual(129, convert_integer_info.convert_integer);

    const convert_interval_day_time_info = try con.getInfo(.convert_interval_day_time);
    try expectEqual(0, convert_interval_day_time_info.convert_interval_day_time);

    const convert_interval_year_month_info = try con.getInfo(.convert_interval_year_month);
    try expectEqual(0, convert_interval_year_month_info.convert_interval_year_month);

    const convert_longvarbinary_info = try con.getInfo(.convert_longvarbinary);
    try expectEqual(0, convert_longvarbinary_info.convert_longvarbinary);

    const convert_longvarchar_info = try con.getInfo(.convert_longvarchar);
    try expectEqual(0, convert_longvarchar_info.convert_longvarchar);

    const convert_numeric_info = try con.getInfo(.convert_numeric);
    try expectEqual(129, convert_numeric_info.convert_numeric);

    const convert_real_info = try con.getInfo(.convert_real);
    try expectEqual(0, convert_real_info.convert_real);

    const convert_smallint_info = try con.getInfo(.convert_smallint);
    try expectEqual(129, convert_smallint_info.convert_smallint);

    const convert_time_info = try con.getInfo(.convert_time);
    try expectEqual(1, convert_time_info.convert_time);

    const convert_timestamp_info = try con.getInfo(.convert_timestamp);
    try expectEqual(1, convert_timestamp_info.convert_timestamp);

    const convert_tinyint_info = try con.getInfo(.convert_tinyint);
    try expectEqual(0, convert_tinyint_info.convert_tinyint);

    const convert_varbinary_info = try con.getInfo(.convert_varbinary);
    try expectEqual(0, convert_varbinary_info.convert_varbinary);

    const convert_varchar_info = try con.getInfo(.convert_varchar);
    try expectEqual(128, convert_varchar_info.convert_varchar);

    const convert_functions_info = try con.getInfo(.convert_functions);
    try expectEqual(3, convert_functions_info.convert_functions);

    const correlation_name_info = try con.getInfo(.correlation_name);
    try expectEqual(
        InfoTypeValue.CorrelationName.any,
        correlation_name_info.correlation_name,
    );

    const create_assertion_info = try con.getInfo(.create_assertion);
    try expectEqual(0, create_assertion_info.create_assertion);

    const create_character_set_info = try con.getInfo(.create_character_set);
    try expectEqual(0, create_character_set_info.create_character_set);

    const create_collation_info = try con.getInfo(.create_collation);
    try expectEqual(0, create_collation_info.create_collation);

    const create_domain_info = try con.getInfo(.create_domain);
    try expectEqual(0, create_domain_info.create_domain);

    const create_schema_info = try con.getInfo(.create_schema);
    try expectEqual(3, create_schema_info.create_schema);

    const create_table_info = try con.getInfo(.create_table);
    try expectEqual(9729, create_table_info.create_table);

    const create_translation_info = try con.getInfo(.create_translation);
    try expectEqual(0, create_translation_info.create_translation);

    const cursor_commit_behavior_info = try con.getInfo(.cursor_commit_behavior);
    try expectEqual(
        InfoTypeValue.CursorBehavior.preserve,
        cursor_commit_behavior_info.cursor_commit_behavior,
    );

    const cursor_rollback_behavior_info = try con.getInfo(.cursor_rollback_behavior);
    try expectEqual(
        InfoTypeValue.CursorBehavior.close,
        cursor_rollback_behavior_info.cursor_rollback_behavior,
    );

    const cursor_sensitivity_info = try con.getInfo(.cursor_sensitivity);
    try expectEqual(
        InfoTypeValue.CursorSensitivity.unspecified,
        cursor_sensitivity_info.cursor_sensitivity,
    );

    const data_source_name_info = try con.getInfoString(allocator, .data_source_name);
    defer allocator.free(data_source_name_info);
    try expectEqualStrings("", data_source_name_info);

    const data_source_read_only_info = try con.getInfo(.data_source_read_only);
    try expectEqual(false, data_source_read_only_info.data_source_read_only);

    const database_name_info = try con.getInfoString(allocator, .database_name);
    defer allocator.free(database_name_info);
    try expectEqualStrings("TESTDB", database_name_info);

    const dbms_name_info = try con.getInfoString(allocator, .dbms_name);
    defer allocator.free(dbms_name_info);
    try expectEqualStrings("DB2/LINUXX8664", dbms_name_info);

    const dbms_ver_info = try con.getInfoString(allocator, .dbms_ver);
    defer allocator.free(dbms_ver_info);
    try expectEqualStrings("11.05.0900", dbms_ver_info);

    const ddl_index_info = try con.getInfo(.ddl_index);
    try expectEqual(3, ddl_index_info.ddl_index);

    const default_txn_isolation_info = try con.getInfo(.default_txn_isolation);
    try expectEqual(2, default_txn_isolation_info.default_txn_isolation);

    const describe_parameter_info = try con.getInfo(.describe_parameter);
    try expectEqual(true, describe_parameter_info.describe_parameter);

    const driver_hdbc_info = try con.getInfo(.driver_hdbc);
    try expect(driver_hdbc_info.driver_hdbc > 0);

    const driver_henv_info = try con.getInfo(.driver_henv);
    try expect(driver_henv_info.driver_henv > 0);

    const driver_hlib_info = try con.getInfo(.driver_hlib);
    try expect(driver_hlib_info.driver_hlib > 0);

    // TODO:
    // - seems to require a statement on the connection
    // const driver_hstmt_info = try con.getInfo( .driver_hstmt);
    // try expect(driver_hstmt_info.DriverHstmt > 0);

    const driver_name_info = try con.getInfoString(allocator, .driver_name);
    defer allocator.free(driver_name_info);
    try expectEqualStrings("libdb2.a", driver_name_info);

    const driver_odbc_ver = try con.getInfoString(allocator, .driver_odbc_ver);
    defer allocator.free(driver_odbc_ver);
    try expectEqualStrings("03.51", driver_odbc_ver);

    const driver_ver_info = try con.getInfoString(allocator, .driver_ver);
    defer allocator.free(driver_ver_info);
    try expectEqualStrings("11.05.0900", driver_ver_info);

    const drop_assertion_info = try con.getInfo(.drop_assertion);
    try expectEqual(0, drop_assertion_info.drop_assertion);

    const drop_character_set_info = try con.getInfo(.drop_character_set);
    try expectEqual(0, drop_character_set_info.drop_character_set);

    const drop_collation_info = try con.getInfo(.drop_collation);
    try expectEqual(0, drop_collation_info.drop_collation);

    const drop_domain_info = try con.getInfo(.drop_domain);
    try expectEqual(0, drop_domain_info.drop_domain);

    const drop_schema_info = try con.getInfo(.drop_schema);
    try expectEqual(3, drop_schema_info.drop_schema);

    const drop_table_info = try con.getInfo(.drop_table);
    try expectEqual(1, drop_table_info.drop_table);

    const drop_translation_info = try con.getInfo(.drop_translation);
    try expectEqual(0, drop_translation_info.drop_translation);

    const drop_view_info = try con.getInfo(.drop_view);
    try expectEqual(1, drop_view_info.drop_view);

    const dynamic_cursor_attributes_1 = try con.getInfo(.dynamic_cursor_attributes1);
    try expectEqual(0, dynamic_cursor_attributes_1.dynamic_cursor_attributes1);

    const dynamic_cursor_attributes_2 = try con.getInfo(.dynamic_cursor_attributes2);
    try expectEqual(0, dynamic_cursor_attributes_2.dynamic_cursor_attributes2);

    const expressions_in_orderby_info = try con.getInfo(.expressions_in_orderby);
    try expectEqual(true, expressions_in_orderby_info.expressions_in_orderby);

    const fetch_direction_info = try con.getInfo(.fetch_direction);
    try expectEqual(255, fetch_direction_info.fetch_direction);

    const forward_only_cursor_attributes_1 = try con.getInfo(.forward_only_cursor_attributes1);
    try expectEqual(57345, forward_only_cursor_attributes_1.forward_only_cursor_attributes1);

    const forward_only_cursor_attributes_2 = try con.getInfo(.forward_only_cursor_attributes2);
    try expectEqual(2179, forward_only_cursor_attributes_2.forward_only_cursor_attributes2);

    const getdata_extensions_info = try con.getInfo(.getdata_extensions);
    try expectEqual(7, getdata_extensions_info.getdata_extensions);

    const group_by_info = try con.getInfo(.group_by);
    try expectEqual(
        InfoTypeValue.GroupBy.group_by_contains_select,
        group_by_info.group_by,
    );

    const identifier_case_info = try con.getInfo(.identifier_case);
    try expectEqual(
        InfoTypeValue.IdentifierCase.upper,
        identifier_case_info.identifier_case,
    );

    const identifier_quote_char_info = try con.getInfoString(allocator, .identifier_quote_char);
    defer allocator.free(identifier_quote_char_info);
    try expectEqualStrings(
        "\"",
        identifier_quote_char_info,
    );

    const info_schema_views_info = try con.getInfo(.info_schema_views);
    try expectEqual(0, info_schema_views_info.info_schema_views);

    const insert_statement_info = try con.getInfo(.insert_statement);
    try expectEqual(7, insert_statement_info.insert_statement);

    const integrity_info = try con.getInfo(.integrity);
    try expectEqual(true, integrity_info.integrity);

    const keyset_cursor_attributes1_info = try con.getInfo(.keyset_cursor_attributes1);
    try expectEqual(990799, keyset_cursor_attributes1_info.keyset_cursor_attributes1);

    const keyset_cursor_attributes2_info = try con.getInfo(.keyset_cursor_attributes2);
    try expectEqual(16395, keyset_cursor_attributes2_info.keyset_cursor_attributes2);

    const keywords_info = try con.getInfoString(allocator, .keywords);
    defer allocator.free(keywords_info);
    try expectEqualStrings(
        "AFTER,ALIAS,ALLOW,APPLICATION,ASSOCIATE,ASUTIME,AUDIT,AUX,AUXILIARY,BEFORE,BINARY,BUFFERPOOL,CACHE,CALL,CALLED,CAPTURE,CARDINALITY,CCSID,CLUSTER,COLLECTION,COLLID,COMMENT,CONCAT,CONDITION,CONTAINS,COUNT_BIG,CURRENT_LC_CTYPE,CURRENT_PATH,CURRENT_SERVER,CURRENT_TIMEZONE,CYCLE,DATA,DATABASE,DAYS,DB2GENERAL,DB2GENRL,DB2SQL,DBINFO,DEFAULTS,DEFINITION,DETERMINISTIC,DISALLOW,DO,DSNHATTR,DSSIZE,DYNAMIC,EACH,EDITPROC,ELSEIF,ENCODING,END-EXEC1,ERASE,EXCLUDING,EXIT,FENCED,FIELDPROC,FILE,FINAL,FREE,FUNCTION,GENERAL,GENERATED,GRAPHIC,HANDLER,HOLD,HOURS,IF,INCLUDING,INCREMENT,INHERIT,INOUT,INTEGRITY,ISOBID,ITERATE,JAR,JAVA,LABEL,LC_CTYPE,LEAVE,LINKTYPE,LOCALE,LOCATOR,LOCATORS,LOCK,LOCKMAX,LOCKSIZE,LONG,LOOP,MAXVALUE,MICROSECOND,MICROSECONDS,MINUTES,MINVALUE,MODE,MODIFIES,MONTHS,NEW,NEW_TABLE,NOCACHE,NOCYCLE,NODENAME,NODENUMBER,NOMAXVALUE,NOMINVALUE,NOORDER,NULLS,NUMPARTS,OBID,OLD,OLD_TABLE,OPTIMIZATION,OPTIMIZE,OUT,OVERRIDING,PACKAGE,PARAMETER,PART,PARTITION,PATH,PIECESIZE,PLAN,PRIQTY,PROGRAM,PSID,QUERYNO,READS,RECOVERY,REFERENCING,RELEASE,RENAME,REPEAT,RESET,RESIGNAL,RESTART,RESULT,RESULT_SET_LOCATOR,RETURN,RETURNS,ROUTINE,ROW,RRN,RUN,SAVEPOINT,SCRATCHPAD,SECONDS,SECQTY,SECURITY,SENSITIVE,SIGNAL,SIMPLE,SOURCE,SPECIFIC,SQLID,STANDARD,START,STATIC,STAY,STOGROUP,STORES,STYLE,SUBPAGES,SYNONYM,SYSFUN,SYSIBM,SYSPROC,SYSTEM,TABLESPACE,TRIGGER,TYPE,UNDO,UNTIL,VALIDPROC,VARIABLE,VARIANT,VCAT,VOLUMES,WHILE,WLM,YEARS",
        keywords_info,
    );

    const like_escape_clause_info = try con.getInfo(.like_escape_clause);
    try expectEqual(true, like_escape_clause_info.like_escape_clause);

    const lock_types_info = try con.getInfo(.lock_types);
    try expectEqual(0, lock_types_info.lock_types);

    const max_async_concurrent_statements_info = try con.getInfo(.max_async_concurrent_statements);
    try expectEqual(1, max_async_concurrent_statements_info.max_async_concurrent_statements);

    const max_binary_literal_len_info = try con.getInfo(.max_binary_literal_len);
    try expectEqual(4000, max_binary_literal_len_info.max_binary_literal_len);

    const max_catalog_name_len_info = try con.getInfo(.max_catalog_name_len);
    try expectEqual(0, max_catalog_name_len_info.max_catalog_name_len);

    const max_char_literal_len_info = try con.getInfo(.max_char_literal_len);
    try expectEqual(32672, max_char_literal_len_info.max_char_literal_len);

    const max_column_name_len_info = try con.getInfo(.max_column_name_len);
    try expectEqual(128, max_column_name_len_info.max_column_name_len);

    const max_columns_in_group_by_info = try con.getInfo(.max_columns_in_group_by);
    try expectEqual(1012, max_columns_in_group_by_info.max_columns_in_group_by);

    const max_columns_in_index_info = try con.getInfo(.max_columns_in_index);
    try expectEqual(16, max_columns_in_index_info.max_columns_in_index);

    const max_columns_in_order_by_info = try con.getInfo(.max_columns_in_order_by);
    try expectEqual(1012, max_columns_in_order_by_info.max_columns_in_order_by);

    const max_columns_in_select_info = try con.getInfo(.max_columns_in_select);
    try expectEqual(1012, max_columns_in_select_info.max_columns_in_select);

    const max_columns_in_table_info = try con.getInfo(.max_columns_in_table);
    try expectEqual(1012, max_columns_in_table_info.max_columns_in_table);

    const max_concurrent_activities_info = try con.getInfo(.max_concurrent_activities);
    try expectEqual(0, max_concurrent_activities_info.max_concurrent_activities);

    const max_cursor_name_len_info = try con.getInfo(.max_cursor_name_len);
    try expectEqual(128, max_cursor_name_len_info.max_cursor_name_len);

    const max_driver_connections_info = try con.getInfo(.max_driver_connections);
    try expectEqual(0, max_driver_connections_info.max_driver_connections);

    const max_identifier_len_info = try con.getInfo(.max_identifier_len);
    try expectEqual(128, max_identifier_len_info.max_identifier_len);

    const max_index_size_info = try con.getInfo(.max_index_size);
    try expectEqual(1024, max_index_size_info.max_index_size);

    const max_procedure_name_len_info = try con.getInfo(.max_procedure_name_len);
    try expectEqual(128, max_procedure_name_len_info.max_procedure_name_len);

    const max_row_size_info = try con.getInfo(.max_row_size);
    try expectEqual(32677, max_row_size_info.max_row_size);

    const max_row_size_includes_long_info = try con.getInfo(.max_row_size_includes_long);
    try expectEqual(false, max_row_size_includes_long_info.max_row_size_includes_long);

    const max_schema_name_len_info = try con.getInfo(.max_schema_name_len);
    try expectEqual(128, max_schema_name_len_info.max_schema_name_len);

    const max_statement_len_info = try con.getInfo(.max_statement_len);
    try expectEqual(2097152, max_statement_len_info.max_statement_len);

    const max_table_name_len_info = try con.getInfo(.max_table_name_len);
    try expectEqual(128, max_table_name_len_info.max_table_name_len);

    const max_tables_in_select_info = try con.getInfo(.max_tables_in_select);
    try expectEqual(0, max_tables_in_select_info.max_tables_in_select);

    const max_user_name_len_info = try con.getInfo(.max_user_name_len);
    try expectEqual(8, max_user_name_len_info.max_user_name_len);

    const mult_result_sets_info = try con.getInfo(.mult_result_sets);
    try expectEqual(true, mult_result_sets_info.mult_result_sets);

    const multiple_active_txn_info = try con.getInfo(.multiple_active_txn);
    try expectEqual(true, multiple_active_txn_info.multiple_active_txn);

    const need_long_data_len_info = try con.getInfo(.need_long_data_len);
    try expectEqual(false, need_long_data_len_info.need_long_data_len);

    const non_nullable_columns_info = try con.getInfo(.non_nullable_columns);
    try expectEqual(
        InfoTypeValue.NonNullableColumns.non_null,
        non_nullable_columns_info.non_nullable_columns,
    );

    const null_collation_info = try con.getInfo(.null_collation);
    try expectEqual(
        InfoTypeValue.NullCollation.high,
        null_collation_info.null_collation,
    );

    const numeric_functions_info = try con.getInfo(.numeric_functions);
    try expectEqual(16777215, numeric_functions_info.numeric_functions);

    const odbc_api_conformance_info = try con.getInfo(.odbc_api_conformance);
    try expectEqual(
        InfoTypeValue.OdbcApiConformance.level2,
        odbc_api_conformance_info.odbc_api_conformance,
    );

    const odbc_sag_cli_conformance_info = try con.getInfo(.odbc_sag_cli_conformance);
    try expectEqual(
        InfoTypeValue.OdbcSagCliConformance.compliant,
        odbc_sag_cli_conformance_info.odbc_sag_cli_conformance,
    );

    const odbc_sql_conformance_info = try con.getInfo(.odbc_sql_conformance);
    try expectEqual(
        InfoTypeValue.OdbcSqlConformance.extended,
        odbc_sql_conformance_info.odbc_sql_conformance,
    );

    const odbc_ver_info = try con.getInfoString(allocator, .odbc_ver);
    defer allocator.free(odbc_ver_info);
    try expectEqualStrings("03.52", odbc_ver_info);

    const oj_capabilities_info = try con.getInfo(.oj_capabilities);
    try expectEqual(127, oj_capabilities_info.oj_capabilities);

    const order_by_columns_in_select_info = try con.getInfo(.order_by_columns_in_select);
    try expectEqual(false, order_by_columns_in_select_info.order_by_columns_in_select);

    const outer_joins_info = try con.getInfo(.outer_joins);
    try expectEqual(true, outer_joins_info.outer_joins);

    const owner_term_info = try con.getInfoString(allocator, .owner_term);
    defer allocator.free(owner_term_info);
    try expectEqualStrings("schema", owner_term_info);

    const param_array_row_counts_info = try con.getInfo(.param_array_row_counts);
    try expectEqual(
        InfoTypeValue.ParamArrayRowCounts.no_batch,
        param_array_row_counts_info.param_array_row_counts,
    );

    const param_array_selects_info = try con.getInfo(.param_array_selects);
    try expectEqual(
        InfoTypeValue.ParamArraySelects.batch,
        param_array_selects_info.param_array_selects,
    );

    const pos_operations_info = try con.getInfo(.pos_operations);
    try expectEqual(31, pos_operations_info.pos_operations);

    const positioned_statements_info = try con.getInfo(.positioned_statements);
    try expectEqual(7, positioned_statements_info.positioned_statements);

    const procedure_term_info = try con.getInfoString(allocator, .procedure_term);
    defer allocator.free(procedure_term_info);
    try expectEqualStrings("stored procedure", procedure_term_info);

    const procedures_info = try con.getInfo(.procedures);
    try expectEqual(true, procedures_info.procedures);

    const quoted_identifier_case_info = try con.getInfo(.quoted_identifier_case);
    try expectEqual(
        InfoTypeValue.QuotedIdentifierCase.sensitive,
        quoted_identifier_case_info.quoted_identifier_case,
    );

    const row_updates_info = try con.getInfo(.row_updates);
    try expectEqual(false, row_updates_info.row_updates);

    const schema_usage_info = try con.getInfo(.schema_usage);
    try expectEqual(31, schema_usage_info.schema_usage);

    const scroll_concurrency_info = try con.getInfo(.scroll_concurrency);
    try expectEqual(11, scroll_concurrency_info.scroll_concurrency);

    const scroll_options_info = try con.getInfo(.scroll_options);
    try expectEqual(19, scroll_options_info.scroll_options);

    const search_pattern_escape_info = try con.getInfoString(allocator, .search_pattern_escape);
    defer allocator.free(search_pattern_escape_info);
    try expectEqualStrings("\\", search_pattern_escape_info);

    const server_name_info = try con.getInfoString(allocator, .server_name);
    defer allocator.free(server_name_info);
    try expectEqualStrings("DB2", server_name_info);

    const special_characters_info = try con.getInfoString(allocator, .special_characters);
    defer allocator.free(special_characters_info);
    try expectEqualStrings("@#", special_characters_info);

    const sql92_predicates_info = try con.getInfo(.sql92_predicates);
    try expectEqual(15879, sql92_predicates_info.sql92_predicates);

    const sql92_value_expressions_info = try con.getInfo(.sql92_value_expressions);
    try expectEqual(15, sql92_value_expressions_info.sql92_value_expressions);

    const static_cursor_attributes_1_info = try con.getInfo(.static_cursor_attributes1);
    try expectEqual(15, static_cursor_attributes_1_info.static_cursor_attributes1);

    const static_cursor_attributes_2_info = try con.getInfo(.static_cursor_attributes2);
    try expectEqual(131, static_cursor_attributes_2_info.static_cursor_attributes2);

    const static_sensitivity_info = try con.getInfo(.static_sensitivity);
    try expectEqual(0, static_sensitivity_info.static_sensitivity);

    const string_functions_info = try con.getInfo(.string_functions);
    try expectEqual(524287, string_functions_info.string_functions);

    const subqueries_info = try con.getInfo(.subqueries);
    try expectEqual(31, subqueries_info.subqueries);

    const system_functions_info = try con.getInfo(.system_functions);
    try expectEqual(7, system_functions_info.system_functions);

    const table_term_info = try con.getInfoString(allocator, .table_term);
    defer allocator.free(table_term_info);
    try expectEqualStrings("table", table_term_info);

    const timedate_add_intervals_info = try con.getInfo(.timedate_add_intervals);
    try expectEqual(511, timedate_add_intervals_info.timedate_add_intervals);

    const timedate_diff_intervals_info = try con.getInfo(.timedate_diff_intervals);
    try expectEqual(511, timedate_diff_intervals_info.timedate_diff_intervals);

    const timedate_functions_info = try con.getInfo(.timedate_functions);
    try expectEqual(131071, timedate_functions_info.timedate_functions);

    const txn_capable_info = try con.getInfo(.txn_capable);
    try expectEqual(
        InfoTypeValue.TxnCapable.all,
        txn_capable_info.txn_capable,
    );

    const txn_isolation_option_info = try con.getInfo(.txn_isolation_option);
    try expectEqual(15, txn_isolation_option_info.txn_isolation_option);

    const union_info = try con.getInfo(.@"union");
    try expectEqual(3, union_info.@"union");

    const user_name_info = try con.getInfoString(allocator, .user_name);
    defer allocator.free(user_name_info);
    try expectEqualStrings("db2inst1", user_name_info);

    const xopen_cli_year_info = try con.getInfoString(allocator, .xopen_cli_year);
    defer allocator.free(xopen_cli_year_info);
    try expectEqualStrings("1995", xopen_cli_year_info);
}
