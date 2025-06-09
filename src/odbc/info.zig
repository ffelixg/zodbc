const std = @import("std");
const builtin = @import("builtin");
const native_endian = builtin.target.cpu.arch.endian();

const mem = @import("mem.zig");
const readInt = mem.readInt;
const strToBool = mem.strToBool;

const c = @import("c");

pub const InfoType = enum(c_int) {
    // ODBC spec
    accessible_procedures = c.SQL_ACCESSIBLE_PROCEDURES,
    accessible_tables = c.SQL_ACCESSIBLE_TABLES,
    active_environments = c.SQL_ACTIVE_ENVIRONMENTS,
    aggregate_functions = c.SQL_AGGREGATE_FUNCTIONS,
    alter_domain = c.SQL_ALTER_DOMAIN,
    alter_table = c.SQL_ALTER_TABLE,
    batch_row_count = c.SQL_BATCH_ROW_COUNT,
    batch_support = c.SQL_BATCH_SUPPORT,
    bookmark_persistence = c.SQL_BOOKMARK_PERSISTENCE,
    catalog_location = c.SQL_CATALOG_LOCATION,
    catalog_name = c.SQL_CATALOG_NAME,
    catalog_name_separator = c.SQL_CATALOG_NAME_SEPARATOR,
    catalog_term = c.SQL_CATALOG_TERM,
    catalog_usage = c.SQL_CATALOG_USAGE,
    collation_seq = c.SQL_COLLATION_SEQ,
    column_alias = c.SQL_COLUMN_ALIAS,
    concat_null_behavior = c.SQL_CONCAT_NULL_BEHAVIOR,
    convert_bigint = c.SQL_CONVERT_BIGINT,
    convert_binary = c.SQL_CONVERT_BINARY,
    convert_bit = c.SQL_CONVERT_BIT,
    convert_char = c.SQL_CONVERT_CHAR,
    convert_date = c.SQL_CONVERT_DATE,
    convert_decimal = c.SQL_CONVERT_DECIMAL,
    convert_double = c.SQL_CONVERT_DOUBLE,
    convert_float = c.SQL_CONVERT_FLOAT,
    convert_integer = c.SQL_CONVERT_INTEGER,
    convert_interval_day_time = c.SQL_CONVERT_INTERVAL_DAY_TIME,
    convert_interval_year_month = c.SQL_CONVERT_INTERVAL_YEAR_MONTH,
    convert_longvarbinary = c.SQL_CONVERT_LONGVARBINARY,
    convert_longvarchar = c.SQL_CONVERT_LONGVARCHAR,
    convert_numeric = c.SQL_CONVERT_NUMERIC,
    convert_real = c.SQL_CONVERT_REAL,
    convert_smallint = c.SQL_CONVERT_SMALLINT,
    convert_time = c.SQL_CONVERT_TIME,
    convert_timestamp = c.SQL_CONVERT_TIMESTAMP,
    convert_tinyint = c.SQL_CONVERT_TINYINT,
    convert_varbinary = c.SQL_CONVERT_VARBINARY,
    convert_varchar = c.SQL_CONVERT_VARCHAR,
    convert_functions = c.SQL_CONVERT_FUNCTIONS,
    correlation_name = c.SQL_CORRELATION_NAME,
    create_assertion = c.SQL_CREATE_ASSERTION,
    create_character_set = c.SQL_CREATE_CHARACTER_SET,
    create_collation = c.SQL_CREATE_COLLATION,
    create_domain = c.SQL_CREATE_DOMAIN,
    create_schema = c.SQL_CREATE_SCHEMA,
    create_table = c.SQL_CREATE_TABLE,
    create_translation = c.SQL_CREATE_TRANSLATION,
    cursor_commit_behavior = c.SQL_CURSOR_COMMIT_BEHAVIOR,
    cursor_rollback_behavior = c.SQL_CURSOR_ROLLBACK_BEHAVIOR,
    cursor_sensitivity = c.SQL_CURSOR_SENSITIVITY,
    data_source_name = c.SQL_DATA_SOURCE_NAME,
    data_source_read_only = c.SQL_DATA_SOURCE_READ_ONLY,
    database_name = c.SQL_DATABASE_NAME,
    dbms_name = c.SQL_DBMS_NAME,
    dbms_ver = c.SQL_DBMS_VER,
    ddl_index = c.SQL_DDL_INDEX,
    default_txn_isolation = c.SQL_DEFAULT_TXN_ISOLATION,
    describe_parameter = c.SQL_DESCRIBE_PARAMETER,
    driver_hdbc = c.SQL_DRIVER_HDBC,
    driver_henv = c.SQL_DRIVER_HENV,
    driver_hlib = c.SQL_DRIVER_HLIB,
    driver_hstmt = c.SQL_DRIVER_HSTMT,
    driver_name = c.SQL_DRIVER_NAME,
    driver_odbc_ver = c.SQL_DRIVER_ODBC_VER,
    driver_ver = c.SQL_DRIVER_VER,
    drop_assertion = c.SQL_DROP_ASSERTION,
    drop_character_set = c.SQL_DROP_CHARACTER_SET,
    drop_collation = c.SQL_DROP_COLLATION,
    drop_domain = c.SQL_DROP_DOMAIN,
    drop_schema = c.SQL_DROP_SCHEMA,
    drop_table = c.SQL_DROP_TABLE,
    drop_translation = c.SQL_DROP_TRANSLATION,
    drop_view = c.SQL_DROP_VIEW,
    dynamic_cursor_attributes1 = c.SQL_DYNAMIC_CURSOR_ATTRIBUTES1,
    dynamic_cursor_attributes2 = c.SQL_DYNAMIC_CURSOR_ATTRIBUTES2,
    expressions_in_orderby = c.SQL_EXPRESSIONS_IN_ORDERBY,
    fetch_direction = c.SQL_FETCH_DIRECTION,
    file_usage = c.SQL_FILE_USAGE,
    forward_only_cursor_attributes1 = c.SQL_FORWARD_ONLY_CURSOR_ATTRIBUTES1,
    forward_only_cursor_attributes2 = c.SQL_FORWARD_ONLY_CURSOR_ATTRIBUTES2,
    getdata_extensions = c.SQL_GETDATA_EXTENSIONS,
    group_by = c.SQL_GROUP_BY,
    identifier_case = c.SQL_IDENTIFIER_CASE,
    identifier_quote_char = c.SQL_IDENTIFIER_QUOTE_CHAR,
    info_schema_views = c.SQL_INFO_SCHEMA_VIEWS,
    insert_statement = c.SQL_INSERT_STATEMENT,
    integrity = c.SQL_INTEGRITY,
    keyset_cursor_attributes1 = c.SQL_KEYSET_CURSOR_ATTRIBUTES1,
    keyset_cursor_attributes2 = c.SQL_KEYSET_CURSOR_ATTRIBUTES2,
    keywords = c.SQL_KEYWORDS,
    like_escape_clause = c.SQL_LIKE_ESCAPE_CLAUSE,
    lock_types = c.SQL_LOCK_TYPES,
    max_async_concurrent_statements = c.SQL_MAX_ASYNC_CONCURRENT_STATEMENTS,
    max_binary_literal_len = c.SQL_MAX_BINARY_LITERAL_LEN,
    max_catalog_name_len = c.SQL_MAX_CATALOG_NAME_LEN,
    max_char_literal_len = c.SQL_MAX_CHAR_LITERAL_LEN,
    max_column_name_len = c.SQL_MAX_COLUMN_NAME_LEN,
    max_columns_in_group_by = c.SQL_MAX_COLUMNS_IN_GROUP_BY,
    max_columns_in_index = c.SQL_MAX_COLUMNS_IN_INDEX,
    max_columns_in_order_by = c.SQL_MAX_COLUMNS_IN_ORDER_BY,
    max_columns_in_select = c.SQL_MAX_COLUMNS_IN_SELECT,
    max_columns_in_table = c.SQL_MAX_COLUMNS_IN_TABLE,
    max_concurrent_activities = c.SQL_MAX_CONCURRENT_ACTIVITIES,
    max_cursor_name_len = c.SQL_MAX_CURSOR_NAME_LEN,
    max_driver_connections = c.SQL_MAX_DRIVER_CONNECTIONS,
    max_identifier_len = c.SQL_MAX_IDENTIFIER_LEN,
    max_index_size = c.SQL_MAX_INDEX_SIZE,
    max_procedure_name_len = c.SQL_MAX_PROCEDURE_NAME_LEN,
    max_row_size = c.SQL_MAX_ROW_SIZE,
    max_row_size_includes_long = c.SQL_MAX_ROW_SIZE_INCLUDES_LONG,
    max_schema_name_len = c.SQL_MAX_SCHEMA_NAME_LEN,
    max_statement_len = c.SQL_MAX_STATEMENT_LEN,
    max_table_name_len = c.SQL_MAX_TABLE_NAME_LEN,
    max_tables_in_select = c.SQL_MAX_TABLES_IN_SELECT,
    max_user_name_len = c.SQL_MAX_USER_NAME_LEN,
    mult_result_sets = c.SQL_MULT_RESULT_SETS,
    multiple_active_txn = c.SQL_MULTIPLE_ACTIVE_TXN,
    need_long_data_len = c.SQL_NEED_LONG_DATA_LEN,
    non_nullable_columns = c.SQL_NON_NULLABLE_COLUMNS,
    null_collation = c.SQL_NULL_COLLATION,
    numeric_functions = c.SQL_NUMERIC_FUNCTIONS,
    odbc_api_conformance = c.SQL_ODBC_API_CONFORMANCE,
    odbc_sag_cli_conformance = c.SQL_ODBC_SAG_CLI_CONFORMANCE,
    odbc_sql_conformance = c.SQL_ODBC_SQL_CONFORMANCE,
    odbc_ver = c.SQL_ODBC_VER,
    oj_capabilities = c.SQL_OJ_CAPABILITIES,
    order_by_columns_in_select = c.SQL_ORDER_BY_COLUMNS_IN_SELECT,
    outer_joins = c.SQL_OUTER_JOINS,
    owner_term = c.SQL_OWNER_TERM,
    param_array_row_counts = c.SQL_PARAM_ARRAY_ROW_COUNTS,
    param_array_selects = c.SQL_PARAM_ARRAY_SELECTS,
    pos_operations = c.SQL_POS_OPERATIONS,
    positioned_statements = c.SQL_POSITIONED_STATEMENTS,
    procedure_term = c.SQL_PROCEDURE_TERM,
    procedures = c.SQL_PROCEDURES,
    quoted_identifier_case = c.SQL_QUOTED_IDENTIFIER_CASE,
    row_updates = c.SQL_ROW_UPDATES,
    schema_usage = c.SQL_SCHEMA_USAGE,
    scroll_concurrency = c.SQL_SCROLL_CONCURRENCY,
    scroll_options = c.SQL_SCROLL_OPTIONS,
    search_pattern_escape = c.SQL_SEARCH_PATTERN_ESCAPE,
    server_name = c.SQL_SERVER_NAME,
    special_characters = c.SQL_SPECIAL_CHARACTERS,
    sql92_predicates = c.SQL_SQL92_PREDICATES,
    sql92_value_expressions = c.SQL_SQL92_VALUE_EXPRESSIONS,
    static_cursor_attributes1 = c.SQL_STATIC_CURSOR_ATTRIBUTES1,
    static_cursor_attributes2 = c.SQL_STATIC_CURSOR_ATTRIBUTES2,
    static_sensitivity = c.SQL_STATIC_SENSITIVITY,
    string_functions = c.SQL_STRING_FUNCTIONS,
    subqueries = c.SQL_SUBQUERIES,
    system_functions = c.SQL_SYSTEM_FUNCTIONS,
    table_term = c.SQL_TABLE_TERM,
    timedate_add_intervals = c.SQL_TIMEDATE_ADD_INTERVALS,
    timedate_diff_intervals = c.SQL_TIMEDATE_DIFF_INTERVALS,
    timedate_functions = c.SQL_TIMEDATE_FUNCTIONS,
    txn_capable = c.SQL_TXN_CAPABLE,
    txn_isolation_option = c.SQL_TXN_ISOLATION_OPTION,
    @"union" = c.SQL_UNION,
    user_name = c.SQL_USER_NAME,
    xopen_cli_year = c.SQL_XOPEN_CLI_YEAR,
    // IBM Db2 specific info types
    // ascii_gccsid = c.SQL_ASCII_GCCSID,
    // ascii_mccsid = c.SQL_ASCII_MCCSID,
    // ascii_sccsid = c.SQL_ASCII_SCCSID,
    // convert_rowid = c.SQL_CONVERT_ROWID,
    // close_behavior = c.SQL_CLOSE_BEHAVIOR,
    // ebcdic_gccsid = c.SQL_EBCDIC_GCCSID,
    // ebcdic_mccsid = c.SQL_EBCDIC_MCCSID,
    // ebcdic_sccsid = c.SQL_EBCDIC_SCCSID,
    // unicode_gccsid = c.SQL_UNICODE_GCCSID,
    // unicode_mccsid = c.SQL_UNICODE_MCCSID,
    // unicode_sccsid = c.SQL_UNICODE_SCCSID,
};

pub const InfoTypeValue = union(InfoType) {
    accessible_procedures: bool,
    accessible_tables: bool,
    active_environments: u16,
    aggregate_functions: AggregateFunctionsMask,
    alter_domain: AlterDomainMask,
    alter_table: AlterTableMask,
    batch_row_count: BatchRowCountMask,
    batch_support: BatchSupportMask,
    bookmark_persistence: BookmarkPersistenceMask,
    catalog_location: u16,
    catalog_name: bool,
    catalog_name_separator: []const u8,
    catalog_term: []const u8,
    catalog_usage: CatalogUsageMask,
    collation_seq: []const u8,
    column_alias: bool,
    concat_null_behavior: ConcatNullBehavior,
    convert_bigint: ConvertBigintMask,
    convert_binary: ConvertBinaryMask,
    convert_bit: ConvertBitMask,
    convert_char: ConvertCharMask,
    convert_date: ConvertDateMask,
    convert_decimal: ConvertDecimalMask,
    convert_double: ConvertDoubleMask,
    convert_float: ConvertFloatMask,
    convert_integer: ConvertIntegerMask,
    convert_interval_day_time: ConvertIntervalDayTimeMask,
    convert_interval_year_month: ConvertIntervalYearMonthMask,
    convert_longvarbinary: ConvertLongvarbinaryMask,
    convert_longvarchar: ConvertLongvarcharMask,
    convert_numeric: ConvertNumericMask,
    convert_real: ConvertRealMask,
    convert_smallint: ConvertSmallintMask,
    convert_time: ConvertTimeMask,
    convert_timestamp: ConvertTimestampMask,
    convert_tinyint: ConvertTinyintMask,
    convert_varbinary: ConvertVarbinaryMask,
    convert_varchar: ConvertVarcharMask,
    convert_functions: ConvertFunctionsMask,
    correlation_name: CorrelationName,
    create_assertion: CreateAssertionMask,
    create_character_set: CreateCharacterSetMask,
    create_collation: CreateCollationMask,
    create_domain: CreateDomainMask,
    create_schema: CreateSchemaMask,
    create_table: CreateTableMask,
    create_translation: CreateTranslationMask,
    cursor_commit_behavior: CursorBehavior,
    cursor_rollback_behavior: CursorBehavior,
    cursor_sensitivity: CursorSensitivity,
    data_source_name: []const u8,
    data_source_read_only: bool,
    database_name: []const u8,
    dbms_name: []const u8,
    dbms_ver: []const u8,
    ddl_index: DdlIndexMask,
    default_txn_isolation: DefaultTxnIsolationMask,
    describe_parameter: bool,
    driver_hdbc: u32,
    driver_henv: u32,
    driver_hlib: u32,
    driver_hstmt: u32,
    driver_name: []const u8,
    driver_odbc_ver: []const u8,
    driver_ver: []const u8,
    drop_assertion: DropAssertionMask,
    drop_character_set: DropCharacterSetMask,
    drop_collation: DropCollationMask,
    drop_domain: DropDomainMask,
    drop_schema: DropSchemaMask,
    drop_table: DropTableMask,
    drop_translation: DropTranslationMask,
    drop_view: DropViewMask,
    dynamic_cursor_attributes1: DynamicCursorAttributes1Mask,
    dynamic_cursor_attributes2: DynamicCursorAttributes2Mask,
    expressions_in_orderby: bool,
    fetch_direction: FetchDirectionMask,
    file_usage: u16,
    forward_only_cursor_attributes1: ForwardOnlyCursorAttributes1Mask,
    forward_only_cursor_attributes2: ForwardOnlyCursorAttributes2Mask,
    getdata_extensions: GetdataExtensionsMask,
    group_by: GroupBy,
    identifier_case: IdentifierCase,
    identifier_quote_char: []const u8,
    info_schema_views: InfoSchemaViewsMask,
    insert_statement: InsertStatementMask,
    integrity: bool,
    keyset_cursor_attributes1: KeysetCursorAttributes1Mask,
    keyset_cursor_attributes2: KeysetCursorAttributes2Mask,
    keywords: []const u8,
    like_escape_clause: bool,
    lock_types: LockTypesMask,
    max_async_concurrent_statements: u32,
    max_binary_literal_len: u32,
    max_catalog_name_len: u16,
    max_char_literal_len: u32,
    max_column_name_len: u16,
    max_columns_in_group_by: u16,
    max_columns_in_index: u16,
    max_columns_in_order_by: u16,
    max_columns_in_select: u16,
    max_columns_in_table: u16,
    max_concurrent_activities: u16,
    max_cursor_name_len: u16,
    max_driver_connections: u16,
    max_identifier_len: u16,
    max_index_size: u32,
    max_procedure_name_len: u16,
    max_row_size: u32,
    max_row_size_includes_long: bool,
    max_schema_name_len: u16,
    max_statement_len: u32,
    max_table_name_len: u16,
    max_tables_in_select: u16,
    max_user_name_len: u16,
    mult_result_sets: bool,
    multiple_active_txn: bool,
    need_long_data_len: bool,
    non_nullable_columns: NonNullableColumns,
    null_collation: NullCollation,
    numeric_functions: NumericFunctionsMask,
    odbc_api_conformance: OdbcApiConformance,
    odbc_sag_cli_conformance: OdbcSagCliConformance,
    odbc_sql_conformance: OdbcSqlConformance,
    odbc_ver: []const u8,
    oj_capabilities: OjCapabilitiesMask,
    order_by_columns_in_select: bool,
    outer_joins: bool,
    owner_term: []const u8,
    param_array_row_counts: ParamArrayRowCounts,
    param_array_selects: ParamArraySelects,
    pos_operations: PosOperationsMask,
    positioned_statements: PositionedStatementsMask,
    procedure_term: []const u8,
    procedures: bool,
    quoted_identifier_case: QuotedIdentifierCase,
    row_updates: bool,
    schema_usage: SchemaUsageMask,
    scroll_concurrency: ScrollConcurrencyMask,
    scroll_options: ScrollOptionsMask,
    search_pattern_escape: []const u8,
    server_name: []const u8,
    special_characters: []const u8,
    sql92_predicates: Sql92PredicatesMask,
    sql92_value_expressions: Sql92ValueExpressionsMask,
    static_cursor_attributes1: StaticCursorAttributes1Mask,
    static_cursor_attributes2: StaticCursorAttributes2Mask,
    static_sensitivity: StaticSensitivityMask,
    string_functions: StringFunctionsMask,
    subqueries: SubqueriesMask,
    system_functions: SystemFunctionsMask,
    table_term: []const u8,
    timedate_add_intervals: TimedateAddIntervalsMask,
    timedate_diff_intervals: TimedateDiffIntervalsMask,
    timedate_functions: TimedateFunctionsMask,
    txn_capable: TxnCapable,
    txn_isolation_option: TxnIsolationOptionMask,
    @"union": UnionMask,
    user_name: []const u8,
    xopen_cli_year: []const u8,
    // IBM Db2 specific info types
    // AsciiGccsid: [buf_len]u8,
    // AsciiMccsid: [buf_len]u8,
    // AsciiSccsid: [buf_len]u8,
    // ConvertRowid: [buf_len]u8,
    // CloseBehavior: [buf_len]u8,
    // EbcdicGccsid: [buf_len]u8,
    // EbcdicMccsid: [buf_len]u8,
    // EbcdicSccsid: [buf_len]u8,
    // UnicodeGccsid: [buf_len]u8,
    // UnicodeMccsid: [buf_len]u8,
    // UnicodeSccsid: [buf_len]u8,

    pub fn init(
        allocator: std.mem.Allocator,
        info_type: InfoType,
        odbc_buf: []u8,
        str_len: i16,
    ) !InfoTypeValue {
        return switch (info_type) {
            .accessible_procedures => .{ .accessible_procedures = strToBool(odbc_buf, str_len, "Y") },
            .accessible_tables => .{ .accessible_tables = strToBool(odbc_buf, str_len, "Y") },
            .active_environments => .{ .active_environments = readInt(u16, odbc_buf) },
            .aggregate_functions => .{ .aggregate_functions = .{ .data = readInt(u32, odbc_buf) } },
            .alter_domain => .{ .alter_domain = .{ .data = readInt(u32, odbc_buf) } },
            .alter_table => .{ .alter_table = .{ .data = readInt(u32, odbc_buf) } },
            .batch_row_count => .{ .batch_row_count = .{ .data = readInt(u32, odbc_buf) } },
            .batch_support => .{ .batch_support = .{ .data = readInt(u32, odbc_buf) } },
            .bookmark_persistence => .{ .bookmark_persistence = .{ .data = readInt(u32, odbc_buf) } },
            .catalog_location => .{ .catalog_location = readInt(u16, odbc_buf) },
            .catalog_name => .{ .catalog_name = strToBool(odbc_buf, str_len, "Y") },
            .catalog_name_separator => {
                const str = try allocator.alloc(u8, @intCast(str_len));
                @memcpy(str, odbc_buf[0..@intCast(str_len)]);
                return .{ .catalog_name_separator = str[0..] };
            },
            .catalog_term => {
                const str = try allocator.alloc(u8, @intCast(str_len));
                @memcpy(str, odbc_buf[0..@intCast(str_len)]);
                return .{ .catalog_term = str[0..] };
            },
            .catalog_usage => .{ .catalog_usage = .{ .data = readInt(u32, odbc_buf) } },
            .collation_seq => {
                const str = try allocator.alloc(u8, @intCast(str_len));
                @memcpy(str, odbc_buf[0..@intCast(str_len)]);
                return .{ .collation_seq = str[0..] };
            },
            .column_alias => .{ .column_alias = strToBool(odbc_buf, str_len, "Y") },
            .concat_null_behavior => .{ .concat_null_behavior = @enumFromInt(readInt(u16, odbc_buf)) },
            .convert_bigint => .{ .convert_bigint = .{ .data = readInt(u32, odbc_buf) } },
            .convert_binary => .{ .convert_binary = .{ .data = readInt(u32, odbc_buf) } },
            .convert_bit => .{ .convert_bit = .{ .data = readInt(u32, odbc_buf) } },
            .convert_char => .{ .convert_char = .{ .data = readInt(u32, odbc_buf) } },
            .convert_date => .{ .convert_date = .{ .data = readInt(u32, odbc_buf) } },
            .convert_decimal => .{ .convert_decimal = .{ .data = readInt(u32, odbc_buf) } },
            .convert_double => .{ .convert_double = .{ .data = readInt(u32, odbc_buf) } },
            .convert_float => .{ .convert_float = .{ .data = readInt(u32, odbc_buf) } },
            .convert_integer => .{ .convert_integer = .{ .data = readInt(u32, odbc_buf) } },
            .convert_interval_day_time => .{ .convert_interval_day_time = .{ .data = readInt(u32, odbc_buf) } },
            .convert_interval_year_month => .{ .convert_interval_year_month = .{ .data = readInt(u32, odbc_buf) } },
            .convert_longvarbinary => .{ .convert_longvarbinary = .{ .data = readInt(u32, odbc_buf) } },
            .convert_longvarchar => .{ .convert_longvarchar = .{ .data = readInt(u32, odbc_buf) } },
            .convert_numeric => .{ .convert_numeric = .{ .data = readInt(u32, odbc_buf) } },
            .convert_real => .{ .convert_real = .{ .data = readInt(u32, odbc_buf) } },
            .convert_smallint => .{ .convert_smallint = .{ .data = readInt(u32, odbc_buf) } },
            .convert_time => .{ .convert_time = .{ .data = readInt(u32, odbc_buf) } },
            .convert_timestamp => .{ .convert_timestamp = .{ .data = readInt(u32, odbc_buf) } },
            .convert_tinyint => .{ .convert_tinyint = .{ .data = readInt(u32, odbc_buf) } },
            .convert_varbinary => .{ .convert_varbinary = .{ .data = readInt(u32, odbc_buf) } },
            .convert_varchar => .{ .convert_varchar = .{ .data = readInt(u32, odbc_buf) } },
            .convert_functions => .{ .convert_functions = .{ .data = readInt(u32, odbc_buf) } },
            .correlation_name => .{ .correlation_name = @enumFromInt(readInt(u16, odbc_buf)) },
            .create_assertion => .{ .create_assertion = .{ .data = readInt(u32, odbc_buf) } },
            .create_character_set => .{ .create_character_set = .{ .data = readInt(u32, odbc_buf) } },
            .create_collation => .{ .create_collation = .{ .data = readInt(u32, odbc_buf) } },
            .create_domain => .{ .create_domain = .{ .data = readInt(u32, odbc_buf) } },
            .create_schema => .{ .create_schema = .{ .data = readInt(u32, odbc_buf) } },
            .create_table => .{ .create_table = .{ .data = readInt(u32, odbc_buf) } },
            .create_translation => .{ .create_translation = .{ .data = readInt(u32, odbc_buf) } },
            .cursor_commit_behavior => .{ .cursor_commit_behavior = @enumFromInt(readInt(u16, odbc_buf)) },
            .cursor_rollback_behavior => .{ .cursor_rollback_behavior = @enumFromInt(readInt(u16, odbc_buf)) },
            .cursor_sensitivity => .{ .cursor_sensitivity = @enumFromInt(readInt(u32, odbc_buf)) },
            .data_source_name => {
                const str = try allocator.alloc(u8, @intCast(str_len));
                @memcpy(str, odbc_buf[0..@intCast(str_len)]);
                return .{ .data_source_name = str[0..] };
            },
            .data_source_read_only => .{ .data_source_read_only = strToBool(odbc_buf, str_len, "Y") },
            .database_name => {
                const str = try allocator.alloc(u8, @intCast(str_len));
                @memcpy(str, odbc_buf[0..@intCast(str_len)]);
                return .{ .database_name = str[0..] };
            },
            .dbms_name => {
                const str = try allocator.alloc(u8, @intCast(str_len));
                @memcpy(str, odbc_buf[0..@intCast(str_len)]);
                return .{ .dbms_name = str[0..] };
            },
            .dbms_ver => {
                const str = try allocator.alloc(u8, @intCast(str_len));
                @memcpy(str, odbc_buf[0..@intCast(str_len)]);
                return .{ .dbms_ver = str[0..] };
            },
            .ddl_index => .{ .ddl_index = .{ .data = readInt(u32, odbc_buf) } },
            .default_txn_isolation => .{ .default_txn_isolation = .{ .data = readInt(u32, odbc_buf) } },
            .describe_parameter => .{ .describe_parameter = strToBool(odbc_buf, str_len, "Y") },
            .driver_hdbc => .{ .driver_hdbc = readInt(u32, odbc_buf) },
            .driver_henv => .{ .driver_henv = readInt(u32, odbc_buf) },
            .driver_hlib => .{ .driver_hlib = readInt(u32, odbc_buf) },
            .driver_hstmt => .{ .driver_hstmt = readInt(u32, odbc_buf) },
            .driver_name => {
                const str = try allocator.alloc(u8, @intCast(str_len));
                @memcpy(str, odbc_buf[0..@intCast(str_len)]);
                return .{ .driver_name = str[0..] };
            },
            .driver_odbc_ver => {
                const str = try allocator.alloc(u8, @intCast(str_len));
                @memcpy(str, odbc_buf[0..@intCast(str_len)]);
                return .{ .driver_odbc_ver = str[0..] };
            },
            .driver_ver => {
                const str = try allocator.alloc(u8, @intCast(str_len));
                @memcpy(str, odbc_buf[0..@intCast(str_len)]);
                return .{ .driver_ver = str[0..] };
            },
            .drop_assertion => .{ .drop_assertion = .{ .data = readInt(u32, odbc_buf) } },
            .drop_character_set => .{ .drop_character_set = .{ .data = readInt(u32, odbc_buf) } },
            .drop_collation => .{ .drop_collation = .{ .data = readInt(u32, odbc_buf) } },
            .drop_domain => .{ .drop_domain = .{ .data = readInt(u32, odbc_buf) } },
            .drop_schema => .{ .drop_schema = .{ .data = readInt(u32, odbc_buf) } },
            .drop_table => .{ .drop_table = .{ .data = readInt(u32, odbc_buf) } },
            .drop_translation => .{ .drop_translation = .{ .data = readInt(u32, odbc_buf) } },
            .drop_view => .{ .drop_view = .{ .data = readInt(u32, odbc_buf) } },
            .dynamic_cursor_attributes1 => .{ .dynamic_cursor_attributes1 = .{ .data = readInt(u32, odbc_buf) } },
            .dynamic_cursor_attributes2 => .{ .dynamic_cursor_attributes2 = .{ .data = readInt(u32, odbc_buf) } },
            .expressions_in_orderby => .{ .expressions_in_orderby = strToBool(odbc_buf, str_len, "Y") },
            .fetch_direction => .{ .fetch_direction = .{ .data = readInt(u32, odbc_buf) } },
            .file_usage => .{ .file_usage = readInt(u16, odbc_buf) },
            .forward_only_cursor_attributes1 => .{ .forward_only_cursor_attributes1 = .{ .data = readInt(u32, odbc_buf) } },
            .forward_only_cursor_attributes2 => .{ .forward_only_cursor_attributes2 = .{ .data = readInt(u32, odbc_buf) } },
            .getdata_extensions => .{ .getdata_extensions = .{ .data = readInt(u32, odbc_buf) } },
            .group_by => .{ .group_by = @enumFromInt(readInt(u16, odbc_buf)) },
            .identifier_case => .{ .identifier_case = @enumFromInt(readInt(u16, odbc_buf)) },
            .identifier_quote_char => {
                const str = try allocator.alloc(u8, @intCast(str_len));
                @memcpy(str, odbc_buf[0..@intCast(str_len)]);
                return .{ .identifier_quote_char = str[0..] };
            },
            .info_schema_views => .{ .info_schema_views = .{ .data = readInt(u32, odbc_buf) } },
            .insert_statement => .{ .insert_statement = .{ .data = readInt(u32, odbc_buf) } },
            .integrity => .{ .integrity = strToBool(odbc_buf, str_len, "Y") },
            .keyset_cursor_attributes1 => .{ .keyset_cursor_attributes1 = .{ .data = readInt(u32, odbc_buf) } },
            .keyset_cursor_attributes2 => .{ .keyset_cursor_attributes2 = .{ .data = readInt(u32, odbc_buf) } },
            .keywords => {
                const str = try allocator.alloc(u8, @intCast(str_len));
                @memcpy(str, odbc_buf[0..@intCast(str_len)]);
                return .{ .keywords = str[0..] };
            },
            .like_escape_clause => .{ .like_escape_clause = strToBool(odbc_buf, str_len, "Y") },
            .lock_types => .{ .lock_types = .{ .data = readInt(u32, odbc_buf) } },
            .max_async_concurrent_statements => .{ .max_async_concurrent_statements = readInt(u32, odbc_buf) },
            .max_binary_literal_len => .{ .max_binary_literal_len = readInt(u32, odbc_buf) },
            .max_catalog_name_len => .{ .max_catalog_name_len = readInt(u16, odbc_buf) },
            .max_char_literal_len => .{ .max_char_literal_len = readInt(u32, odbc_buf) },
            .max_column_name_len => .{ .max_column_name_len = readInt(u16, odbc_buf) },
            .max_columns_in_group_by => .{ .max_columns_in_group_by = readInt(u16, odbc_buf) },
            .max_columns_in_index => .{ .max_columns_in_index = readInt(u16, odbc_buf) },
            .max_columns_in_order_by => .{ .max_columns_in_order_by = readInt(u16, odbc_buf) },
            .max_columns_in_select => .{ .max_columns_in_select = readInt(u16, odbc_buf) },
            .max_columns_in_table => .{ .max_columns_in_table = readInt(u16, odbc_buf) },
            .max_concurrent_activities => .{ .max_concurrent_activities = readInt(u16, odbc_buf) },
            .max_cursor_name_len => .{ .max_cursor_name_len = readInt(u16, odbc_buf) },
            .max_driver_connections => .{ .max_driver_connections = readInt(u16, odbc_buf) },
            .max_identifier_len => .{ .max_identifier_len = readInt(u16, odbc_buf) },
            .max_index_size => .{ .max_index_size = readInt(u32, odbc_buf) },
            .max_procedure_name_len => .{ .max_procedure_name_len = readInt(u16, odbc_buf) },
            .max_row_size => .{ .max_row_size = readInt(u32, odbc_buf) },
            .max_row_size_includes_long => .{ .max_row_size_includes_long = strToBool(odbc_buf, str_len, "Y") },
            .max_schema_name_len => .{ .max_schema_name_len = readInt(u16, odbc_buf) },
            .max_statement_len => .{ .max_statement_len = readInt(u32, odbc_buf) },
            .max_table_name_len => .{ .max_table_name_len = readInt(u16, odbc_buf) },
            .max_tables_in_select => .{ .max_tables_in_select = readInt(u16, odbc_buf) },
            .max_user_name_len => .{ .max_user_name_len = readInt(u16, odbc_buf) },
            .mult_result_sets => .{ .mult_result_sets = strToBool(odbc_buf, str_len, "Y") },
            .multiple_active_txn => .{ .multiple_active_txn = strToBool(odbc_buf, str_len, "Y") },
            .need_long_data_len => .{ .need_long_data_len = strToBool(odbc_buf, str_len, "Y") },
            .non_nullable_columns => .{ .non_nullable_columns = @enumFromInt(readInt(u16, odbc_buf)) },
            .null_collation => .{ .null_collation = @enumFromInt(readInt(u16, odbc_buf)) },
            .numeric_functions => .{ .numeric_functions = .{ .data = readInt(u32, odbc_buf) } },
            .odbc_api_conformance => .{ .odbc_api_conformance = @enumFromInt(readInt(u16, odbc_buf)) },
            .odbc_sag_cli_conformance => .{ .odbc_sag_cli_conformance = @enumFromInt(readInt(u16, odbc_buf)) },
            .odbc_sql_conformance => .{ .odbc_sql_conformance = @enumFromInt(readInt(u16, odbc_buf)) },
            .odbc_ver => {
                const str = try allocator.alloc(u8, @intCast(str_len));
                @memcpy(str, odbc_buf[0..@intCast(str_len)]);
                return .{ .odbc_ver = str[0..] };
            },
            .oj_capabilities => .{ .oj_capabilities = .{ .data = readInt(u32, odbc_buf) } },
            .order_by_columns_in_select => .{ .order_by_columns_in_select = strToBool(odbc_buf, str_len, "Y") },
            .outer_joins => .{ .outer_joins = strToBool(odbc_buf, str_len, "Y") },
            .owner_term => {
                const str = try allocator.alloc(u8, @intCast(str_len));
                @memcpy(str, odbc_buf[0..@intCast(str_len)]);
                return .{ .owner_term = str[0..] };
            },
            .param_array_row_counts => .{ .param_array_row_counts = @enumFromInt(readInt(u32, odbc_buf)) },
            .param_array_selects => .{ .param_array_selects = @enumFromInt(readInt(u32, odbc_buf)) },
            .pos_operations => .{ .pos_operations = .{ .data = readInt(u32, odbc_buf) } },
            .positioned_statements => .{ .positioned_statements = .{ .data = readInt(u32, odbc_buf) } },
            .procedure_term => {
                const str = try allocator.alloc(u8, @intCast(str_len));
                @memcpy(str, odbc_buf[0..@intCast(str_len)]);
                return .{ .procedure_term = str[0..] };
            },
            .procedures => .{ .procedures = strToBool(odbc_buf, str_len, "Y") },
            .quoted_identifier_case => .{ .quoted_identifier_case = @enumFromInt(readInt(u16, odbc_buf)) },
            .row_updates => .{ .row_updates = strToBool(odbc_buf, str_len, "Y") },
            .schema_usage => .{ .schema_usage = .{ .data = readInt(u32, odbc_buf) } },
            .scroll_concurrency => .{ .scroll_concurrency = .{ .data = readInt(u32, odbc_buf) } },
            .scroll_options => .{ .scroll_options = .{ .data = readInt(u32, odbc_buf) } },
            .search_pattern_escape => {
                const str = try allocator.alloc(u8, @intCast(str_len));
                @memcpy(str, odbc_buf[0..@intCast(str_len)]);
                return .{ .search_pattern_escape = str[0..] };
            },
            .server_name => {
                const str = try allocator.alloc(u8, @intCast(str_len));
                @memcpy(str, odbc_buf[0..@intCast(str_len)]);
                return .{ .server_name = str[0..] };
            },
            .special_characters => {
                const str = try allocator.alloc(u8, @intCast(str_len));
                @memcpy(str, odbc_buf[0..@intCast(str_len)]);
                return .{ .special_characters = str[0..] };
            },
            .sql92_predicates => .{ .sql92_predicates = .{ .data = readInt(u32, odbc_buf) } },
            .sql92_value_expressions => .{ .sql92_value_expressions = .{ .data = readInt(u32, odbc_buf) } },
            .static_cursor_attributes1 => .{ .static_cursor_attributes1 = .{ .data = readInt(u32, odbc_buf) } },
            .static_cursor_attributes2 => .{ .static_cursor_attributes2 = .{ .data = readInt(u32, odbc_buf) } },
            .static_sensitivity => .{ .static_sensitivity = .{ .data = readInt(u32, odbc_buf) } },
            .string_functions => .{ .string_functions = .{ .data = readInt(u32, odbc_buf) } },
            .subqueries => .{ .subqueries = .{ .data = readInt(u32, odbc_buf) } },
            .system_functions => .{ .system_functions = .{ .data = readInt(u32, odbc_buf) } },
            .table_term => {
                const str = try allocator.alloc(u8, @intCast(str_len));
                @memcpy(str, odbc_buf[0..@intCast(str_len)]);
                return .{ .table_term = str[0..] };
            },
            .timedate_add_intervals => .{ .timedate_add_intervals = .{ .data = readInt(u32, odbc_buf) } },
            .timedate_diff_intervals => .{ .timedate_diff_intervals = .{ .data = readInt(u32, odbc_buf) } },
            .timedate_functions => .{ .timedate_functions = .{ .data = readInt(u32, odbc_buf) } },
            .txn_capable => .{ .txn_capable = @enumFromInt(readInt(u16, odbc_buf)) },
            .txn_isolation_option => .{ .txn_isolation_option = .{ .data = readInt(u32, odbc_buf) } },
            .@"union" => .{ .@"union" = .{ .data = readInt(u32, odbc_buf) } },
            .user_name => {
                const str = try allocator.alloc(u8, @intCast(str_len));
                @memcpy(str, odbc_buf[0..@intCast(str_len)]);
                return .{ .user_name = str[0..] };
            },
            .xopen_cli_year => {
                const str = try allocator.alloc(u8, @intCast(str_len));
                @memcpy(str, odbc_buf[0..@intCast(str_len)]);
                return .{ .xopen_cli_year = str[0..] };
            },
            // IBM Db2 specific info types
            // .AsciiGccsid => .{ .AsciiGccsid = value },
            // .AsciiMccsid => .{ .AsciiMccsid = value },
            // .AsciiSccsid => .{ .AsciiSccsid = value },
            // .ConvertRowid => .{ .ConvertRowid = value },
            // .CloseBehavior => .{ .CloseBehavior = value },
            // .EbcdicGccsid => .{ .EbcdicGccsid = value },
            // .EbcdicMccsid => .{ .EbcdicMccsid = value },
            // .EbcdicSccsid => .{ .EbcdicSccsid = value },
            // .UnicodeGccsid => .{ .UnicodeGccsid = value },
            // .UnicodeMccsid => .{ .UnicodeMccsid = value },
            // .UnicodeSccsid => .{ .UnicodeSccsid = value },
        };
    }

    pub fn deinit(self: InfoTypeValue, allocator: std.mem.Allocator) void {
        return switch (self) {
            .catalog_name_separator => |v| allocator.free(v),
            .catalog_term => |v| allocator.free(v),
            .collation_seq => |v| allocator.free(v),
            .data_source_name => |v| allocator.free(v),
            .database_name => |v| allocator.free(v),
            .dbms_name => |v| allocator.free(v),
            .dbms_ver => |v| allocator.free(v),
            .driver_name => |v| allocator.free(v),
            .driver_odbc_ver => |v| allocator.free(v),
            .driver_ver => |v| allocator.free(v),
            .identifier_quote_char => |v| allocator.free(v),
            .keywords => |v| allocator.free(v),
            .odbc_ver => |v| allocator.free(v),
            .owner_term => |v| allocator.free(v),
            .procedure_term => |v| allocator.free(v),
            .search_pattern_escape => |v| allocator.free(v),
            .server_name => |v| allocator.free(v),
            .special_characters => |v| allocator.free(v),
            .table_term => |v| allocator.free(v),
            .user_name => |v| allocator.free(v),
            .xopen_cli_year => |v| allocator.free(v),
            else => {},
        };
    }

    pub const AggregateFunctionsMask = struct {
        data: u32 = undefined,
    };

    pub const AlterDomainMask = struct {
        data: u32 = undefined,
    };

    pub const AlterTableMask = struct {
        data: u32 = undefined,
    };

    pub const BatchRowCountMask = struct {
        data: u32 = undefined,
    };

    pub const BatchSupportMask = struct {
        data: u32 = undefined,
    };

    pub const BookmarkPersistenceMask = struct {
        data: u32 = undefined,
    };

    pub const CatalogUsageMask = struct {
        data: u32 = undefined,
    };

    pub const ConvertBigintMask = struct {
        data: u32 = undefined,
    };

    pub const ConcatNullBehavior = enum(c_int) {
        null = c.SQL_CB_NULL,
        non_null = c.SQL_CB_NON_NULL,
    };

    pub const ConvertBinaryMask = struct {
        data: u32 = undefined,
    };

    pub const ConvertBitMask = struct {
        data: u32 = undefined,
    };

    pub const ConvertCharMask = struct {
        data: u32 = undefined,
    };

    pub const ConvertDateMask = struct {
        data: u32 = undefined,
    };

    pub const ConvertDecimalMask = struct {
        data: u32 = undefined,
    };

    pub const ConvertDoubleMask = struct {
        data: u32 = undefined,
    };

    pub const ConvertFloatMask = struct {
        data: u32 = undefined,
    };

    pub const ConvertIntegerMask = struct {
        data: u32 = undefined,
    };

    pub const ConvertIntervalDayTimeMask = struct {
        data: u32 = undefined,
    };

    pub const ConvertIntervalYearMonthMask = struct {
        data: u32 = undefined,
    };

    pub const ConvertLongvarbinaryMask = struct {
        data: u32 = undefined,
    };

    pub const ConvertLongvarcharMask = struct {
        data: u32 = undefined,
    };

    pub const ConvertNumericMask = struct {
        data: u32 = undefined,
    };

    pub const ConvertRealMask = struct {
        data: u32 = undefined,
    };

    pub const ConvertSmallintMask = struct {
        data: u32 = undefined,
    };

    pub const ConvertTimeMask = struct {
        data: u32 = undefined,
    };

    pub const ConvertTimestampMask = struct {
        data: u32 = undefined,
    };

    pub const ConvertTinyintMask = struct {
        data: u32 = undefined,
    };

    pub const ConvertVarbinaryMask = struct {
        data: u32 = undefined,
    };

    pub const ConvertVarcharMask = struct {
        data: u32 = undefined,
    };

    pub const ConvertFunctionsMask = struct {
        data: u32 = undefined,
    };

    pub const CorrelationName = enum(c_int) {
        any = c.SQL_CN_ANY,
        none = c.SQL_CN_NONE,
        different = c.SQL_CN_DIFFERENT,
    };

    pub const CreateAssertionMask = struct {
        data: u32 = undefined,
    };

    pub const CreateCharacterSetMask = struct {
        data: u32 = undefined,
    };

    pub const CreateCollationMask = struct {
        data: u32 = undefined,
    };

    pub const CreateDomainMask = struct {
        data: u32 = undefined,
    };

    pub const CreateSchemaMask = struct {
        data: u32 = undefined,
    };

    pub const CreateTableMask = struct {
        data: u32 = undefined,
    };

    pub const CreateTranslationMask = struct {
        data: u32 = undefined,
    };

    pub const CursorBehavior = enum(c_int) {
        delete = c.SQL_CB_DELETE,
        close = c.SQL_CB_CLOSE,
        preserve = c.SQL_CB_PRESERVE,
    };

    pub const CursorSensitivity = enum(c_int) {
        insensitive = c.SQL_INSENSITIVE,
        unspecified = c.SQL_UNSPECIFIED,
        sensitive = c.SQL_SENSITIVE,
    };

    pub const DdlIndexMask = struct {
        data: u32 = undefined,
    };

    pub const DefaultTxnIsolationMask = struct {
        data: u32 = undefined,
    };

    pub const DropAssertionMask = struct {
        data: u32 = undefined,
    };

    pub const DropCharacterSetMask = struct {
        data: u32 = undefined,
    };

    pub const DropCollationMask = struct {
        data: u32 = undefined,
    };

    pub const DropDomainMask = struct {
        data: u32 = undefined,
    };

    pub const DropSchemaMask = struct {
        data: u32 = undefined,
    };

    pub const DropTableMask = struct {
        data: u32 = undefined,
    };

    pub const DropTranslationMask = struct {
        data: u32 = undefined,
    };

    pub const DropViewMask = struct {
        data: u32 = undefined,
    };

    pub const DynamicCursorAttributes1Mask = struct {
        data: u32 = undefined,
    };

    pub const DynamicCursorAttributes2Mask = struct {
        data: u32 = undefined,
    };

    pub const FetchDirectionMask = struct {
        data: u32 = undefined,
    };

    pub const ForwardOnlyCursorAttributes1Mask = struct {
        data: u32 = undefined,
    };

    pub const ForwardOnlyCursorAttributes2Mask = struct {
        data: u32 = undefined,
    };

    pub const GetdataExtensionsMask = struct {
        data: u32 = undefined,
    };

    pub const GroupBy = enum(c_int) {
        no_relation = c.SQL_GB_NO_RELATION,
        not_supported = c.SQL_GB_NOT_SUPPORTED,
        group_by_equals_select = c.SQL_GB_GROUP_BY_EQUALS_SELECT,
        group_by_contains_select = c.SQL_GB_GROUP_BY_CONTAINS_SELECT,
    };

    pub const IdentifierCase = enum(c_int) {
        upper = c.SQL_IC_UPPER,
        lower = c.SQL_IC_LOWER,
        sensitive = c.SQL_IC_SENSITIVE,
        mixed = c.SQL_IC_MIXED,
    };

    pub const InfoSchemaViewsMask = struct {
        data: u32 = undefined,
    };

    pub const InsertStatementMask = struct {
        data: u32 = undefined,
    };

    pub const KeysetCursorAttributes1Mask = struct {
        data: u32 = undefined,
    };

    pub const KeysetCursorAttributes2Mask = struct {
        data: u32 = undefined,
    };

    pub const LockTypesMask = struct {
        data: u32 = undefined,
    };

    pub const NonNullableColumns = enum(c_int) {
        non_null = c.SQL_NNC_NON_NULL,
        null = c.SQL_NNC_NULL,
    };

    pub const NullCollation = enum(c_int) {
        high = c.SQL_NC_HIGH,
        low = c.SQL_NC_LOW,
    };

    pub const NumericFunctionsMask = struct {
        data: u32 = undefined,
    };

    pub const OdbcApiConformance = enum(c_int) {
        none = c.SQL_OAC_NONE,
        level1 = c.SQL_OAC_LEVEL1,
        level2 = c.SQL_OAC_LEVEL2,
    };

    pub const OdbcSagCliConformance = enum(c_int) {
        not_compliant = c.SQL_OSCC_NOT_COMPLIANT,
        compliant = c.SQL_OSCC_COMPLIANT,
    };

    pub const OdbcSqlConformance = enum(c_int) {
        minimum = c.SQL_OSC_MINIMUM,
        core = c.SQL_OSC_CORE,
        extended = c.SQL_OSC_EXTENDED,
    };

    pub const OjCapabilitiesMask = struct {
        data: u32 = undefined,
    };

    pub const ParamArrayRowCounts = enum(c_int) {
        batch = c.SQL_PARC_BATCH,
        no_batch = c.SQL_PARC_NO_BATCH,
    };

    pub const ParamArraySelects = enum(c_int) {
        batch = c.SQL_PAS_BATCH,
        no_batch = c.SQL_PAS_NO_BATCH,
        no_select = c.SQL_PAS_NO_SELECT,
    };

    pub const PosOperationsMask = struct {
        data: u32 = undefined,
    };

    pub const PositionedStatementsMask = struct {
        data: u32 = undefined,
    };

    pub const QuotedIdentifierCase = enum(c_int) {
        upper = c.SQL_IC_UPPER,
        lower = c.SQL_IC_LOWER,
        sensitive = c.SQL_IC_SENSITIVE,
        mixed = c.SQL_IC_MIXED,
    };

    pub const SchemaUsageMask = struct {
        data: u32 = undefined,
    };

    pub const ScrollConcurrencyMask = struct {
        data: u32 = undefined,
    };

    pub const ScrollOptionsMask = struct {
        data: u32 = undefined,
    };

    pub const Sql92PredicatesMask = struct {
        data: u32 = undefined,
    };

    pub const Sql92ValueExpressionsMask = struct {
        data: u32 = undefined,
    };

    pub const StaticCursorAttributes1Mask = struct {
        data: u32 = undefined,
    };

    pub const StaticCursorAttributes2Mask = struct {
        data: u32 = undefined,
    };

    pub const StaticSensitivityMask = struct {
        data: u32 = undefined,
    };

    pub const StringFunctionsMask = struct {
        data: u32 = undefined,
    };

    pub const SubqueriesMask = struct {
        data: u32 = undefined,
    };

    pub const SystemFunctionsMask = struct {
        data: u32 = undefined,
    };

    pub const TimedateAddIntervalsMask = struct {
        data: u32 = undefined,
    };

    pub const TimedateDiffIntervalsMask = struct {
        data: u32 = undefined,
    };

    pub const TimedateFunctionsMask = struct {
        data: u32 = undefined,
    };

    pub const TxnCapable = enum(c_int) {
        upper = c.SQL_TC_NONE,
        dml = c.SQL_TC_DML,
        ddl_commit = c.SQL_TC_DDL_COMMIT,
        ddl_ignore = c.SQL_TC_DDL_IGNORE,
        all = c.SQL_TC_ALL,
    };

    pub const TxnIsolationOptionMask = struct {
        data: u32 = undefined,
    };

    pub const UnionMask = struct {
        data: u32 = undefined,
    };
};
