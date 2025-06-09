const std = @import("std");

const mem = @import("mem.zig");
const types = @import("types.zig");
const readInt = mem.readInt;

const c = @import("c");

/// IRD array status
pub const RowStatus = enum(u16) {
    success = c.SQL_ROW_SUCCESS,
    success_with_info = c.SQL_ROW_SUCCESS_WITH_INFO,
    err = c.SQL_ROW_ERROR,
    updated = c.SQL_ROW_UPDATED,
    deleted = c.SQL_ROW_DELETED,
    added = c.SQL_ROW_ADDED,
    norow = c.SQL_ROW_NOROW,
};

/// IPD array status
pub const ParamStatus = enum(u16) {
    success = c.SQL_PARAM_SUCCESS,
    success_with_info = c.SQL_PARAM_SUCCESS_WITH_INFO,
    err = c.SQL_PARAM_ERROR,
    unused = c.SQL_PARAM_UNUSED,
    diag_unavailable = c.SQL_PARAM_DIAG_UNAVAILABLE,
};

/// ARD array status
pub const RowOperation = enum(u16) {
    proceed = c.SQL_ROW_PROCEED,
    ignore = c.SQL_ROW_IGNORE,
};

/// APD array status
pub const ParamOperation = enum(u16) {
    proceed = c.SQL_PARAM_PROCEED,
    ignore = c.SQL_PARAM_IGNORE,
};

pub const DateTimeIntervalCode = enum(i16) {
    no_datetime_or_interval = 0,
    year = c.SQL_CODE_YEAR,
    month = c.SQL_CODE_MONTH,
    day = c.SQL_CODE_DAY,
    hour = c.SQL_CODE_HOUR,
    minute = c.SQL_CODE_MINUTE,
    second = c.SQL_CODE_SECOND,
    year_to_month = c.SQL_CODE_YEAR_TO_MONTH,
    day_to_hour = c.SQL_CODE_DAY_TO_HOUR,
    day_to_minute = c.SQL_CODE_DAY_TO_MINUTE,
    day_to_second = c.SQL_CODE_DAY_TO_SECOND,
    hour_to_minute = c.SQL_CODE_HOUR_TO_MINUTE,
    hour_to_second = c.SQL_CODE_HOUR_TO_SECOND,
    minute_to_second = c.SQL_CODE_MINUTE_TO_SECOND,
};

pub const Nullable = enum(i16) {
    nullable = c.SQL_NULLABLE,
    no_nulls = c.SQL_NO_NULLS,
    nullable_unknown = c.SQL_NULLABLE_UNKNOWN,
};

pub const NumPrecRadix = enum(i16) {
    approximate_numeric = 2,
    exact_numeric = 10,
    non_numeric = 0,
};

pub const Searchable = enum(i16) {
    unsearchable = c.SQL_PRED_NONE,
    searchable_like_only = c.SQL_PRED_CHAR,
    searchable_no_like = c.SQL_PRED_BASIC,
    searchable = c.SQL_PRED_SEARCHABLE,
};

pub const Unnamed = enum(i16) {
    named = c.SQL_NAMED,
    unnamed = c.SQL_UNNAMED,
};

pub const Updatable = enum(i16) {
    read_only = c.SQL_ATTR_READONLY,
    write = c.SQL_ATTR_WRITE,
    unknown = c.SQL_ATTR_READWRITE_UNKNOWN,
};

pub const ParameterType = enum(i16) {
    input = c.SQL_PARAM_INPUT,
    output = c.SQL_PARAM_OUTPUT,
    output_stream = c.SQL_PARAM_OUTPUT_STREAM,
    input_output = c.SQL_PARAM_INPUT_OUTPUT,
    input_output_stream = c.SQL_PARAM_INPUT_OUTPUT_STREAM,
};

pub const AllocType = enum(i16) {
    alloc_auto = c.SQL_DESC_ALLOC_AUTO,
    alloc_user = c.SQL_DESC_ALLOC_USER,
};

//
// Environment
//

/// The integer codes for ODBC compliant environment attributes
pub const EnvironmentAttribute = enum(c_int) {
    // ODBC spec
    odbc_version = c.SQL_ATTR_ODBC_VERSION,
    output_nts = c.SQL_ATTR_OUTPUT_NTS,
    connection_pooling = c.SQL_ATTR_CONNECTION_POOLING,
    cp_match = c.SQL_ATTR_CP_MATCH,
    // unixODBC additions
    unixodbc_syspath = c.SQL_ATTR_UNIXODBC_SYSPATH,
    unixodbc_version = c.SQL_ATTR_UNIXODBC_VERSION,
    unixodbc_envattr = c.SQL_ATTR_UNIXODBC_ENVATTR,
    // IBM Db2 specific additions
    // - https://www.ibm.com/docs/en/db2-for-zos/11?topic=functions-sqlsetenvattr-set-environment-attributes
    // info_acctstr = c.SQL_ATTR_INFO_ACCTSTR,
    // info_applname = c.SQL_ATTR_INFO_APPLNAME,
    // info_userid = c.SQL_ATTR_INFO_USERID,
    // info_wrkstnname = c.SQL_ATTR_INFO_WRKSTNNAME,
    // info_connecttype = c.SQL_ATTR_INFO_CONNECTTYPE,
    // info_maxconn = c.SQL_ATTR_INFO_MAXCONN,
};

pub const EnvironmentAttributeValue = union(EnvironmentAttribute) {
    odbc_version: OdbcVersion,
    output_nts: OutputNts,
    connection_pooling: ConnectionPooling,
    cp_match: CpMatch,
    unixodbc_syspath: []const u8,
    unixodbc_version: []const u8,
    unixodbc_envattr: []const u8,

    pub fn init(
        allocator: std.mem.Allocator,
        attr: EnvironmentAttribute,
        odbc_buf: []u8,
        str_len: i32,
    ) !EnvironmentAttributeValue {
        return switch (attr) {
            .odbc_version => .{ .odbc_version = @enumFromInt(readInt(u32, odbc_buf)) },
            .connection_pooling => .{ .connection_pooling = @enumFromInt(readInt(u32, odbc_buf)) },
            .cp_match => .{ .cp_match = @enumFromInt(readInt(u32, odbc_buf)) },
            .output_nts => .{ .output_nts = @enumFromInt(readInt(u32, odbc_buf)) },
            .unixodbc_syspath => {
                const str = try allocator.alloc(u8, @intCast(str_len));
                @memcpy(str, odbc_buf[0..@intCast(str_len)]);
                return .{ .unixodbc_syspath = str[0..] };
            },
            .unixodbc_version => {
                const str = try allocator.alloc(u8, @intCast(str_len));
                @memcpy(str, odbc_buf[0..@intCast(str_len)]);
                return .{ .unixodbc_version = str[0..] };
            },
            .unixodbc_envattr => {
                const str = try allocator.alloc(u8, @intCast(str_len));
                @memcpy(str, odbc_buf[0..@intCast(str_len)]);
                return .{ .unixodbc_envattr = str[0..] };
            },
        };
    }

    pub fn deinit(
        self: EnvironmentAttributeValue,
        allocator: std.mem.Allocator,
    ) void {
        return switch (self) {
            .odbc_version, .connection_pooling, .cp_match, .output_nts => {},
            .unixodbc_syspath => |v| allocator.free(v),
            .unixodbc_version => |v| allocator.free(v),
            .unixodbc_envattr => |v| allocator.free(v),
        };
    }

    pub fn getActiveTag(self: EnvironmentAttributeValue) EnvironmentAttribute {
        return std.meta.activeTag(self);
    }

    pub fn getValue(self: EnvironmentAttributeValue) *allowzero anyopaque {
        return switch (self) {
            .odbc_version => |v| @ptrFromInt(@as(usize, @intFromEnum(v))),
            .connection_pooling => |v| @ptrFromInt(@as(usize, @intFromEnum(v))),
            .cp_match => |v| @ptrFromInt(@as(usize, @intFromEnum(v))),
            .output_nts => |v| @ptrFromInt(@as(usize, @intCast(@intFromEnum(v)))),
            .unixodbc_syspath, .unixodbc_version, .unixodbc_envattr => |v| @ptrCast(@constCast(v)),
        };
    }

    pub fn getStrLen(self: EnvironmentAttributeValue) i32 {
        return switch (self) {
            .odbc_version, .output_nts, .connection_pooling, .cp_match => 0,
            .unixodbc_syspath, .unixodbc_version, .unixodbc_envattr => |v| @intCast(v.len),
        };
    }

    pub const OdbcVersion = enum(c_ulong) {
        v2 = c.SQL_OV_ODBC2,
        v3 = c.SQL_OV_ODBC3,
        v3_80 = c.SQL_OV_ODBC3_80,
    };

    pub const OutputNts = enum(c_int) {
        true = c.SQL_TRUE,
        false = c.SQL_FALSE,
    };

    pub const ConnectionPooling = enum(c_ulong) {
        off = c.SQL_CP_OFF,
        one_per_driver = c.SQL_CP_ONE_PER_DRIVER,
        one_per_henv = c.SQL_CP_ONE_PER_HENV,
    };

    pub const CpMatch = enum(c_ulong) {
        strict_match = c.SQL_CP_STRICT_MATCH,
        relaxed_match = c.SQL_CP_RELAXED_MATCH,
    };
};

//
// Connection
//

/// The integer codes for ODBC compliant connection attributes
pub const ConnectionAttribute = enum(c_int) {
    // ODBC spec
    connection_dead = c.SQL_ATTR_CONNECTION_DEAD,
    driver_threading = c.SQL_ATTR_DRIVER_THREADING,
    // ODBC spec >= 3.0
    access_mode = c.SQL_ATTR_ACCESS_MODE,
    autocommit = c.SQL_ATTR_AUTOCOMMIT,
    connection_timeout = c.SQL_ATTR_CONNECTION_TIMEOUT,
    // current_catalog = c.SQL_ATTR_CURRENT_CATALOG,
    disconnect_behavior = c.SQL_ATTR_DISCONNECT_BEHAVIOR,
    enlist_in_dtc = c.SQL_ATTR_ENLIST_IN_DTC,
    // enlist_in_xa = c.SQL_ATTR_ENLIST_IN_XA,
    login_timeout = c.SQL_ATTR_LOGIN_TIMEOUT,
    odbc_cursors = c.SQL_ATTR_ODBC_CURSORS,
    packet_size = c.SQL_ATTR_PACKET_SIZE,
    // quiet_mode = c.SQL_ATTR_QUIET_MODE,
    trace = c.SQL_ATTR_TRACE,
    // trace_file = c.SQL_ATTR_TRACEFILE,
    // translate_lib = c.SQL_ATTR_TRANSLATE_LIB,
    // translate_option = c.SQL_ATTR_TRANSLATE_OPTION,
    txn_isolation = c.SQL_ATTR_TXN_ISOLATION,
    // ODBC spec >= 3.51
    ansi_app = c.SQL_ATTR_ANSI_APP,
    async_enable = c.SQL_ATTR_ASYNC_ENABLE,
    auto_ipd = c.SQL_ATTR_AUTO_IPD,
    // ODBC spec >= 3.80
    reset_connection = c.SQL_ATTR_RESET_CONNECTION,
    async_dbc_functions_enable = c.SQL_ATTR_ASYNC_DBC_FUNCTIONS_ENABLE,
    // Not sure what this group should be?
    // IBM Db2 specific additions
    // - https://www.ibm.com/docs/en/db2-for-zos/13?topic=functions-sqlsetconnectattr-set-connection-attributes
    // https://github.com/strongloop-forks/node-ibm_db/blob/master/deps/db2cli/include/sqlcli1.h#L690
    // client_time_zone = c.SQL_ATTR_CLIENT_TIME_ZONE,
    // concurrent_access_resolution = c.SQL_ATTR_CONCURRENT_ACCESS_RESOLUTION,
    // connecttype = c.SQL_ATTR_CONNECTTYPE,
    // current_schema = c.SQL_ATTR_CURRENT_SCHEMA,
    // db2_explain = c.SQL_ATTR_DB2_EXPLAIN,
    // decfloat_rounding_mode = c.SQL_ATTR_DECFLOAT_ROUNDING_MODE,
    // extended_indicators = c.SQL_ATTR_EXTENDED_INDICATORS,
    // info_acctstr = c.SQL_ATTR_INFO_ACCTSTR,
    // info_applname = c.SQL_ATTR_INFO_APPLNAME,
    // info_userid = c.SQL_ATTR_INFO_USERID,
    // info_wrkstnname = c.SQL_ATTR_INFO_WRKSTNNAME,
    // keep_dynamic = c.SQL_ATTR_KEEP_DYNAMIC,
    // maxconn = c.SQL_ATTR_MAXCONN,
    // metadata_id = c.SQL_ATTR_METADATA_ID,
    // session_time_zone = c.SQL_ATTR_SESSION_TIME_ZONE,
    // sync_point = c.SQL_ATTR_SYNC_POINT,
    // fet_buf_size = c.SQL_ATTR_FET_BUF_SIZE,
    fet_buf_size = 3001,
};

pub const ConnectionAttributeValue = union(ConnectionAttribute) {
    connection_dead: ConnectionDead,
    driver_threading: u16,
    access_mode: AccessMode,
    autocommit: Autocommit,
    connection_timeout: u32,
    // current_catalog: CurrentCatalog,
    disconnect_behavior: DisconnectBehavior,
    enlist_in_dtc: EnlistInDtc,
    // enlist_in_xa: EnlistInXa,
    login_timeout: u32,
    odbc_cursors: OdbcCursors,
    packet_size: u32,
    // quiet_mode: QuietMode,
    trace: Trace,
    // trace_file: []const u8,
    // translate_lib: []const u8,
    // translate_option: []const u8,
    txn_isolation: TxnIsolation,
    ansi_app: AnsiApp,
    async_enable: AsyncEnable,
    auto_ipd: AutoIpd,
    reset_connection: ResetConnection,
    async_dbc_functions_enable: AsyncDbcFunctionsEnable,
    fet_buf_size: u32,

    pub fn init(
        allocator: std.mem.Allocator,
        attr: ConnectionAttribute,
        odbc_buf: []u8,
        str_len: i32,
    ) !ConnectionAttributeValue {
        _ = str_len;
        _ = allocator;
        return switch (attr) {
            .connection_dead => .{ .connection_dead = @enumFromInt(readInt(i64, odbc_buf)) },
            .driver_threading => .{ .driver_threading = readInt(u16, odbc_buf) },
            .access_mode => .{ .access_mode = @enumFromInt(readInt(i32, odbc_buf)) },
            .autocommit => .{ .autocommit = @enumFromInt(readInt(u64, odbc_buf)) },
            .connection_timeout => .{ .connection_timeout = readInt(u32, odbc_buf) },
            // .current_catalog => .{ .current_catalog = readInt(u32, odbc_buf) },
            .disconnect_behavior => .{ .txn_isolation = @enumFromInt(readInt(i64, odbc_buf)) },
            .enlist_in_dtc => .{ .enlist_in_dtc = @enumFromInt(readInt(u32, odbc_buf)) },
            // .enlist_in_xa => .{ .enlist_in_xa = @enumFromInt(readInt(u32, odbc_buf)) },
            .login_timeout => .{ .login_timeout = readInt(u32, odbc_buf) },
            .odbc_cursors => .{ .odbc_cursors = @enumFromInt(readInt(u32, odbc_buf)) },
            .packet_size => .{ .packet_size = readInt(u32, odbc_buf) },
            // .quiet_mode => .{ .quiet_mode = readInt(u32, odbc_buf) },
            .trace => .{ .trace = @enumFromInt(readInt(u32, odbc_buf)) },
            // .trace_file => {
            //     const str = try allocator.alloc(u8, @intCast(str_len));
            //     @memcpy(str, odbc_buf[0..@intCast(str_len)]);
            //     return .{ .trace_file = str[0..] };
            // },
            // .translate_lib => {
            //     const str = try allocator.alloc(u8, @intCast(str_len));
            //     @memcpy(str, odbc_buf[0..@intCast(str_len)]);
            //     return .{ .translate_lib = str[0..] };
            // },
            // .translate_option => {
            //     const str = try allocator.alloc(u8, @intCast(str_len));
            //     @memcpy(str, odbc_buf[0..@intCast(str_len)]);
            //     return .{ .translate_option = str[0..] };
            // },
            .txn_isolation => .{ .txn_isolation = @enumFromInt(readInt(u32, odbc_buf)) },
            .ansi_app => .{ .ansi_app = @enumFromInt(readInt(u32, odbc_buf)) },
            .async_enable => .{ .async_enable = @enumFromInt(readInt(u32, odbc_buf)) },
            .auto_ipd => .{ .auto_ipd = @enumFromInt(readInt(u32, odbc_buf)) },
            .reset_connection => .{ .reset_connection = @enumFromInt(readInt(u32, odbc_buf)) },
            .async_dbc_functions_enable => .{ .async_dbc_functions_enable = @enumFromInt(readInt(u32, odbc_buf)) },
            .fet_buf_size => .{ .fet_buf_size = readInt(u32, odbc_buf) },
        };
    }

    pub fn deinit(
        self: ConnectionAttributeValue,
        allocator: std.mem.Allocator,
    ) void {
        _ = allocator;
        _ = self;
        // return switch (self) {
        //     .OdbcVersion, .ConnectionPooling, .CpMatch, .OutputNts => {},
        //     .UnixodbcSyspath => |v| allocator.free(v),
        // };
    }

    pub fn getActiveTag(self: ConnectionAttributeValue) ConnectionAttribute {
        return std.meta.activeTag(self);
    }

    pub fn getValue(self: ConnectionAttributeValue) *allowzero anyopaque {
        return switch (self) {
            // .unixodbc_syspath, .unixodbc_version, .unixodbc_envattr => |v| @ptrCast(@constCast(v)),
            .connection_dead => |v| @ptrFromInt(@as(usize, @intCast(@intFromEnum(v)))),
            .driver_threading => |v| @ptrFromInt(@as(usize, v)),
            .access_mode => |v| @ptrFromInt(@as(usize, @intCast(@intFromEnum(v)))),
            .autocommit => |v| @ptrFromInt(@as(usize, @intFromEnum(v))),
            .connection_timeout => |v| @ptrFromInt(@as(usize, v)),
            .disconnect_behavior => |v| @ptrFromInt(@as(usize, @intFromEnum(v))),
            .enlist_in_dtc => |v| @ptrFromInt(@as(usize, @intCast(@intFromEnum(v)))),
            // .enlistt_in_xa => |v| @ptrFromInt(@as(usize, @intFromEnum(v))),
            .login_timeout => |v| @ptrFromInt(@as(usize, v)),
            .odbc_cursors => |v| @ptrFromInt(@as(usize, @intFromEnum(v))),
            .packet_size => |v| @ptrFromInt(@as(usize, v)),
            // .quiet_mode => |v| @ptrFromInt(@as(usize, v)),
            .trace => |v| @ptrFromInt(@as(usize, @intFromEnum(v))),
            .txn_isolation => |v| @ptrFromInt(@as(usize, @intCast(@intFromEnum(v)))),
            .ansi_app => |v| @ptrFromInt(@as(usize, @intCast(@intFromEnum(v)))),
            .async_enable => |v| @ptrFromInt(@as(usize, @intFromEnum(v))),
            .auto_ipd => |v| @ptrFromInt(@as(usize, @intCast(@intFromEnum(v)))),
            .reset_connection => |v| @ptrFromInt(@as(usize, @intFromEnum(v))),
            .async_dbc_functions_enable => |v| @ptrFromInt(@as(usize, @intCast(@intFromEnum(v)))),
            .fet_buf_size => |v| @ptrFromInt(@as(usize, v)),
        };
    }

    pub fn getStrLen(self: ConnectionAttributeValue) i32 {
        return switch (self) {
            .connection_dead,
            .driver_threading,
            .access_mode,
            .autocommit,
            .connection_timeout,
            .disconnect_behavior,
            .enlist_in_dtc,
            // .enlistt_in_xa,
            .login_timeout,
            .odbc_cursors,
            .packet_size,
            // .quiet_mode,
            .trace,
            .txn_isolation,
            .ansi_app,
            .auto_ipd,
            .reset_connection,
            .async_dbc_functions_enable,
            .fet_buf_size,
            => 0,
            // .current_catalog, .trace_file, .translate_lib, .translate_option => |v| @intCast(v.len),
            else => 1,
        };
    }

    pub const ConnectionDead = enum(c_long) {
        true = c.SQL_CD_TRUE,
        false = c.SQL_CD_FALSE,
    };

    pub const AccessMode = enum(c_int) {
        read_write = c.SQL_MODE_READ_WRITE,
        read_only = c.SQL_MODE_READ_ONLY,
    };

    pub const Autocommit = enum(c_ulong) {
        off = c.SQL_AUTOCOMMIT_OFF,
        on = c.SQL_AUTOCOMMIT_ON,
    };

    pub const DisconnectBehavior = enum(c_ulong) {
        return_to_pool = c.SQL_DB_RETURN_TO_POOL,
        disconnect = c.SQL_DB_DISCONNECT,
    };

    pub const EnlistInDtc = enum(c_long) {
        enlist_expensive = c.SQL_DTC_ENLIST_EXPENSIVE,
        unenlist_expensive = c.SQL_DTC_UNENLIST_EXPENSIVE,
    };

    pub const OdbcCursors = enum(c_ulong) {
        if_needed = c.SQL_CUR_USE_IF_NEEDED,
        use_odbc = c.SQL_CUR_USE_ODBC,
        use_driver = c.SQL_CUR_USE_DRIVER,
    };

    pub const Trace = enum(c_ulong) {
        off = c.SQL_OPT_TRACE_OFF,
        on = c.SQL_OPT_TRACE_ON,
    };

    pub const TxnIsolation = enum(c_long) {
        read_uncommitted = c.SQL_TXN_READ_UNCOMMITTED,
        read_committed = c.SQL_TRANSACTION_READ_COMMITTED,
        repeatable_read = c.SQL_TXN_REPEATABLE_READ,
        serializable = c.SQL_TXN_SERIALIZABLE,
    };

    pub const AnsiApp = enum(c_long) {
        true = c.SQL_AA_TRUE,
        false = c.SQL_AA_FALSE,
    };

    pub const AsyncEnable = enum(c_ulong) {
        off = c.SQL_ASYNC_ENABLE_OFF,
        on = c.SQL_ASYNC_ENABLE_ON,
    };

    pub const AutoIpd = enum(c_int) {
        true = c.SQL_TRUE,
        false = c.SQL_FALSE,
    };

    pub const ResetConnection = enum(c_ulong) {
        yes = c.SQL_RESET_CONNECTION_YES,
    };

    pub const AsyncDbcFunctionsEnable = enum(c_int) {
        on = c.SQL_ASYNC_DBC_ENABLE_ON,
        off = c.SQL_ASYNC_DBC_ENABLE_OFF,
    };
};

//
// Statement
// https://learn.microsoft.com/en-us/sql/odbc/reference/syntax/sqlsetstmtattr-function?view=sql-server-ver16
//

pub const StmtAttr = enum(i32) {
    app_param_desc = c.SQL_ATTR_APP_PARAM_DESC,
    app_row_desc = c.SQL_ATTR_APP_ROW_DESC,
    async_enable = c.SQL_ATTR_ASYNC_ENABLE,
    async_stmt_event = c.SQL_ATTR_ASYNC_STMT_EVENT,
    // async_stmt_pcallback = c.SQL_ATTR_ASYNC_STMT_PCALLBACK,
    // async_stmt_pcontext = c.SQL_ATTR_ASYNC_STMT_PCONTEXT,
    concurrency = c.SQL_ATTR_CONCURRENCY,
    cursor_scrollable = c.SQL_ATTR_CURSOR_SCROLLABLE,
    cursor_sensitivity = c.SQL_ATTR_CURSOR_SENSITIVITY,
    cursor_type = c.SQL_ATTR_CURSOR_TYPE,
    enable_auto_ipd = c.SQL_ATTR_ENABLE_AUTO_IPD,
    fetch_bookmark_ptr = c.SQL_ATTR_FETCH_BOOKMARK_PTR,
    imp_param_desc = c.SQL_ATTR_IMP_PARAM_DESC,
    imp_row_desc = c.SQL_ATTR_IMP_ROW_DESC,
    keyset_size = c.SQL_ATTR_KEYSET_SIZE,
    max_length = c.SQL_ATTR_MAX_LENGTH,
    max_rows = c.SQL_ATTR_MAX_ROWS,
    metadata_id = c.SQL_ATTR_METADATA_ID,
    noscan = c.SQL_ATTR_NOSCAN,
    param_bind_offset_ptr = c.SQL_ATTR_PARAM_BIND_OFFSET_PTR,
    param_bind_type = c.SQL_ATTR_PARAM_BIND_TYPE,
    param_operation_ptr = c.SQL_ATTR_PARAM_OPERATION_PTR,
    param_status_ptr = c.SQL_ATTR_PARAM_STATUS_PTR,
    params_processed_ptr = c.SQL_ATTR_PARAMS_PROCESSED_PTR,
    paramset_size = c.SQL_ATTR_PARAMSET_SIZE,
    query_timeout = c.SQL_ATTR_QUERY_TIMEOUT,
    retrieve_data = c.SQL_ATTR_RETRIEVE_DATA,
    row_array_size = c.SQL_ATTR_ROW_ARRAY_SIZE,
    row_bind_offset_ptr = c.SQL_ATTR_ROW_BIND_OFFSET_PTR,
    row_bind_type = c.SQL_ATTR_ROW_BIND_TYPE,
    row_number = c.SQL_ATTR_ROW_NUMBER,
    row_operation_ptr = c.SQL_ATTR_ROW_OPERATION_PTR,
    row_status_ptr = c.SQL_ATTR_ROW_STATUS_PTR,
    rows_fetched_ptr = c.SQL_ATTR_ROWS_FETCHED_PTR,
    simulate_cursor = c.SQL_ATTR_SIMULATE_CURSOR,
    use_bookmarks = c.SQL_ATTR_USE_BOOKMARKS,
};

pub const StmtAttrValue = extern union {
    /// 0 if binding by column, sizeof struct if binding by row
    row_bind_type: u64,
    row_status_ptr: ?[*]RowStatus,
    row_array_size: u64,
    rows_fetched_ptr: *u64,
};

pub const StmtAttrHandle = enum(u16) {
    app_param_desc = c.SQL_ATTR_APP_PARAM_DESC,
    app_row_desc = c.SQL_ATTR_APP_ROW_DESC,
    imp_param_desc = c.SQL_ATTR_IMP_PARAM_DESC,
    imp_row_desc = c.SQL_ATTR_IMP_ROW_DESC,
};

pub const StmtAttrU16Ptr = enum(u16) {
    param_operation_ptr = c.SQL_ATTR_PARAM_OPERATION_PTR,
    param_status_ptr = c.SQL_ATTR_PARAM_STATUS_PTR,
    row_operation_ptr = c.SQL_ATTR_ROW_OPERATION_PTR,
    row_status_ptr = c.SQL_ATTR_ROW_STATUS_PTR,
};

pub const StmtAttrU64Ptr = enum(u16) {
    param_bind_offset_ptr = c.SQL_ATTR_PARAM_BIND_OFFSET_PTR,
    params_processed_ptr = c.SQL_ATTR_PARAMS_PROCESSED_PTR,
    row_bind_offset_ptr = c.SQL_ATTR_ROW_BIND_OFFSET_PTR,
    rows_fetched_ptr = c.SQL_ATTR_ROWS_FETCHED_PTR,
};

//
// TODO
// SQL_ATTR_ASYNC_ENABLE (ODBC 1.0) A SQLULEN value that specifies whether a function called with the specified statement is executed asynchronously:
// SQL_ATTR_ASYNC_STMT_EVENT (ODBC 3.8) A SQLPOINTER value that is an event handle.
// SQL_ATTR_ASYNC_STMT_PCALLBACK (ODBC 3.8) A SQLPOINTER to the asynchronous callback function.
// SQL_ATTR_ASYNC_STMT_PCONTEXT (ODBC 3.8) A SQLPOINTER to the context structure
// SQL_ATTR_CONCURRENCY (ODBC 2.0) An SQLULEN value that specifies the cursor concurrency:
// SQL_ATTR_CURSOR_SCROLLABLE (ODBC 3.0) An SQLULEN value that specifies the level of support that the application requires. Setting this attribute affects subsequent calls to SQLExecDirect and SQLExecute.
// SQL_ATTR_CURSOR_SENSITIVITY (ODBC 3.0) An SQLULEN value that specifies whether cursors on the statement handle make visible the changes made to a result set by another cursor. Setting this attribute affects subsequent calls to SQLExecDirect and SQLExecute. An application can read back the value of this attribute to obtain its initial state or its state as most recently set by the application.
// SQL_ATTR_CURSOR_TYPE (ODBC 2.0) An SQLULEN value that specifies the cursor type:
// SQL_ATTR_ENABLE_AUTO_IPD (ODBC 3.0) An SQLULEN value that specifies whether automatic population of the IPD is performed:
// SQL_ATTR_KEYSET_SIZE (ODBC 2.0) An SQLULEN that specifies the number of rows in the keyset for a keyset-driven cursor. If the keyset size is 0 (the default), the cursor is fully keyset-driven. If the keyset size is greater than 0, the cursor is mixed (keyset-driven within the keyset and dynamic outside of the keyset). The default keyset size is 0. For more information about keyset-driven cursors, see Keyset-Driven Cursors.
// SQL_ATTR_MAX_LENGTH (ODBC 1.0) An SQLULEN value that specifies the maximum amount of data that the driver returns from a character or binary column. If ValuePtr is less than the length of the available data, SQLFetch or SQLGetData truncates the data and returns SQL_SUCCESS. If ValuePtr is 0 (the default), the driver attempts to return all available data.
// SQL_ATTR_MAX_ROWS (ODBC 1.0) An SQLULEN value corresponding to the maximum number of rows to return to the application for a SELECT statement. If *ValuePtr equals 0 (the default), the driver returns all rows.
// SQL_ATTR_METADATA_ID (ODBC 3.0) An SQLULEN value that determines how the string arguments of catalog functions are treated.
// SQL_ATTR_NOSCAN (ODBC 1.0) An SQLULEN value that indicates whether the driver should scan SQL strings for escape sequences:
// SQL_ATTR_PARAM_BIND_TYPE (ODBC 3.0) An SQLULEN value that indicates the binding orientation to be used for dynamic parameters.
// SQL_ATTR_PARAMSET_SIZE (ODBC 3.0) An SQLULEN value that specifies the number of values for each parameter. If SQL_ATTR_PARAMSET_SIZE is greater than 1, SQL_DESC_DATA_PTR, SQL_DESC_INDICATOR_PTR, and SQL_DESC_OCTET_LENGTH_PTR of the APD point to arrays. The cardinality of each array is equal to the value of this field.
// SQL_ATTR_QUERY_TIMEOUT (ODBC 1.0) An SQLULEN value corresponding to the number of seconds to wait for a SQL statement to execute before returning to the application. If ValuePtr is equal to 0 (default), there is no timeout.
// SQL_ATTR_RETRIEVE_DATA (ODBC 2.0) An SQLULEN value:
// SQL_ATTR_ROW_ARRAY_SIZE (ODBC 3.0) An SQLULEN value that specifies the number of rows returned by each call to SQLFetch or SQLFetchScroll. It is also the number of rows in a bookmark array used in a bulk bookmark operation in SQLBulkOperations. The default value is 1.
// SQL_ATTR_ROW_BIND_TYPE (ODBC 1.0) An SQLULEN value that sets the binding orientation to be used when SQLFetch or SQLFetchScroll is called on the associated statement. Column-wise binding is selected by setting the value to SQL_BIND_BY_COLUMN. Row-wise binding is selected by setting the value to the length of a structure or an instance of a buffer into which result columns will be bound.
// SQL_ATTR_ROW_NUMBER (ODBC 2.0) An SQLULEN value that is the number of the current row in the entire result set. If the number of the current row cannot be determined or there is no current row, the driver returns 0.
// SQL_ATTR_SIMULATE_CURSOR (ODBC 2.0) An SQLULEN value that specifies whether drivers that simulate positioned update and delete statements guarantee that such statements affect only one single row.
// SQL_ATTR_USE_BOOKMARKS (ODBC 2.0) An SQLULEN value that specifies whether an application will use bookmarks with a cursor:

// SQL_ATTR_FETCH_BOOKMARK_PTR (ODBC 3.0) A SQLLEN * that points to a binary bookmark value. When SQLFetchScroll is called with fFetchOrientation equal to SQL_FETCH_BOOKMARK, the driver picks up the bookmark value from this field. This field defaults to a null pointer. For more information, see Scrolling by Bookmark.

//
// Column
//

/// The integer codes for ODBC compliant column attributes
pub const ColAttributeString = enum(u16) {
    base_column_name = c.SQL_DESC_BASE_COLUMN_NAME,
    base_table_name = c.SQL_DESC_BASE_TABLE_NAME,
    catalog_name = c.SQL_DESC_CATALOG_NAME,
    label = c.SQL_DESC_LABEL,
    literal_prefix = c.SQL_DESC_LITERAL_PREFIX,
    literal_suffix = c.SQL_DESC_LITERAL_SUFFIX,
    local_type_name = c.SQL_DESC_LOCAL_TYPE_NAME,
    name = c.SQL_DESC_NAME,
    schema_name = c.SQL_DESC_SCHEMA_NAME,
    table_name = c.SQL_DESC_TABLE_NAME,
    type_name = c.SQL_DESC_TYPE_NAME,
};

pub const ColAttributeInt = enum(u16) {
    count = c.SQL_DESC_COUNT,
    display_size = c.SQL_DESC_DISPLAY_SIZE,
    length = c.SQL_DESC_LENGTH,
    octet_length = c.SQL_DESC_OCTET_LENGTH,
    precision = c.SQL_DESC_PRECISION,
    scale = c.SQL_DESC_SCALE,
};

pub const ColAttributeBool = enum(u16) {
    auto_unique_value = c.SQL_DESC_AUTO_UNIQUE_VALUE,
    case_sensitive = c.SQL_DESC_CASE_SENSITIVE,
    fixed_prec_scale = c.SQL_DESC_FIXED_PREC_SCALE,
    unsigned = c.SQL_DESC_UNSIGNED,
};

pub const ColAttributeEnum = enum(u16) {
    concise_type = c.SQL_DESC_CONCISE_TYPE,
    nullable = c.SQL_DESC_NULLABLE,
    num_prec_radix = c.SQL_DESC_NUM_PREC_RADIX,
    searchable = c.SQL_DESC_SEARCHABLE,
    type = c.SQL_DESC_TYPE,
    unnamed = c.SQL_DESC_UNNAMED,
    updatable = c.SQL_DESC_UPDATABLE,
};

pub const ColAttributeEnumValue = union(ColAttributeEnum) {
    concise_type: types.SQLDataType,
    nullable: Nullable,
    num_prec_radix: NumPrecRadix,
    searchable: Searchable,
    type: types.SQLDataType,
    unnamed: Unnamed,
    updatable: Updatable,

    pub fn init(
        attr: ColAttributeEnum,
        num_val: i64,
    ) !ColAttributeEnumValue {
        return switch (attr) {
            .concise_type => .{ .concise_type = @enumFromInt(num_val) },
            .nullable => .{ .nullable = @enumFromInt(num_val) },
            .num_prec_radix => .{ .num_prec_radix = @enumFromInt(num_val) },
            .searchable => .{ .searchable = @enumFromInt(num_val) },
            .type => .{ .type = @enumFromInt(num_val) },
            .unnamed => .{ .unnamed = @enumFromInt(num_val) },
            .updatable => .{ .updatable = @enumFromInt(num_val) },
        };
    }
};
/// The integer codes for ODBC compliant column attributes
pub const ColAttribute = enum(u16) {
    count = c.SQL_DESC_COUNT,
    display_size = c.SQL_DESC_DISPLAY_SIZE,
    length = c.SQL_DESC_LENGTH,
    octet_length = c.SQL_DESC_OCTET_LENGTH,
    precision = c.SQL_DESC_PRECISION,
    scale = c.SQL_DESC_SCALE,
    auto_unique_value = c.SQL_DESC_AUTO_UNIQUE_VALUE,
    case_sensitive = c.SQL_DESC_CASE_SENSITIVE,
    fixed_prec_scale = c.SQL_DESC_FIXED_PREC_SCALE,
    unsigned = c.SQL_DESC_UNSIGNED,
    concise_type = c.SQL_DESC_CONCISE_TYPE,
    nullable = c.SQL_DESC_NULLABLE,
    num_prec_radix = c.SQL_DESC_NUM_PREC_RADIX,
    searchable = c.SQL_DESC_SEARCHABLE,
    type = c.SQL_DESC_TYPE,
    unnamed = c.SQL_DESC_UNNAMED,
    updatable = c.SQL_DESC_UPDATABLE,
};

pub const ColAttributeValue = union(ColAttribute) {
    count: i64,
    display_size: i64,
    length: i64,
    octet_length: i64,
    precision: i64,
    scale: i64,
    auto_unique_value: bool,
    case_sensitive: bool,
    fixed_prec_scale: bool,
    unsigned: bool,
    concise_type: types.SQLDataType,
    nullable: Nullable,
    num_prec_radix: NumPrecRadix,
    searchable: Searchable,
    type: types.SQLDataType,
    unnamed: Unnamed,
    updatable: Updatable,

    pub fn init(
        attr: ColAttributeEnum,
        num_val: i64,
    ) !ColAttributeEnumValue {
        return switch (attr) {
            .concise_type => .{ .concise_type = @enumFromInt(num_val) },
            .nullable => .{ .nullable = @enumFromInt(num_val) },
            .num_prec_radix => .{ .num_prec_radix = @enumFromInt(num_val) },
            .searchable => .{ .searchable = @enumFromInt(num_val) },
            .type => .{ .type = @enumFromInt(num_val) },
            .unnamed => .{ .unnamed = @enumFromInt(num_val) },
            .updatable => .{ .updatable = @enumFromInt(num_val) },
        };
    }
};
