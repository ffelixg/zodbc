const std = @import("std");

const mem = @import("mem.zig");
const types = @import("types.zig");
const readInt = mem.readInt;

pub const c = @cImport({
    @cInclude("sql.h");
    @cInclude("sqltypes.h");
    @cInclude("sqlext.h");
});

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
            .connection_dead => .{ .ConnectionDead = @enumFromInt(readInt(i64, odbc_buf)) },
            .driver_threading => .{ .DriverThreading = readInt(u16, odbc_buf) },
            .access_mode => .{ .AccessMode = @enumFromInt(readInt(i32, odbc_buf)) },
            .autocommit => .{ .Autocommit = @enumFromInt(readInt(u64, odbc_buf)) },
            .connection_timeout => .{ .ConnectionTimeout = readInt(u32, odbc_buf) },
            // .current_catalog => .{ .CurrentCatalog = readInt(u32, odbc_buf) },
            .disconnect_behavior => .{ .TxnIsolation = @enumFromInt(readInt(i64, odbc_buf)) },
            .enlist_in_dtc => .{ .EnlistInDtc = @enumFromInt(readInt(u32, odbc_buf)) },
            // .enlist_in_xa => .{ .EnlistInXa = @enumFromInt(readInt(u32, odbc_buf)) },
            .login_timeout => .{ .LoginTimeout = readInt(u32, odbc_buf) },
            .odbc_cursors => .{ .OdbcCursors = @enumFromInt(readInt(u32, odbc_buf)) },
            .packet_size => .{ .PacketSize = readInt(u32, odbc_buf) },
            // .quiet_mode => .{ .QuietMode = readInt(u32, odbc_buf) },
            .trace => .{ .Trace = @enumFromInt(readInt(u32, odbc_buf)) },
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
            .txn_isolation => .{ .TxnIsolation = @enumFromInt(readInt(u32, odbc_buf)) },
            .ansi_app => .{ .AnsiApp = @enumFromInt(readInt(u32, odbc_buf)) },
            .async_enable => .{ .AsyncEnable = @enumFromInt(readInt(u32, odbc_buf)) },
            .auto_ipd => .{ .AutoIpd = @enumFromInt(readInt(u32, odbc_buf)) },
            .reset_connection => .{ .ResetConnection = @enumFromInt(readInt(u32, odbc_buf)) },
            .async_dbc_functions_enable => .{ .AsyncDbcFunctionsEnable = @enumFromInt(readInt(u32, odbc_buf)) },
            .fet_buf_size => .{ .FetBufSize = readInt(u32, odbc_buf) },
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

    const Nullable = enum(i64) {
        nullable = c.SQL_NULLABLE,
        no_nulls = c.SQL_NO_NULLS,
        nullable_unknown = c.SQL_NULLABLE_UNKNOWN,
    };
    const NumPrecRadix = enum(i64) {
        approximate_numeric = 2,
        exact_numeric = 10,
        non_numeric = 0,
    };
    const Searchable = enum(i64) {
        unsearchable = c.SQL_PRED_NONE,
        searchable_like_only = c.SQL_PRED_CHAR,
        searchable_no_like = c.SQL_PRED_BASIC,
        searchable = c.SQL_PRED_SEARCHABLE,
    };
    const Unnamed = enum(i64) {
        named = c.SQL_NAMED,
        unnamed = c.SQL_UNNAMED,
    };
    const Updatable = enum(i64) {
        read_only = c.SQL_ATTR_READONLY,
        write = c.SQL_ATTR_WRITE,
        unknown = c.SQL_ATTR_READWRITE_UNKNOWN,
    };

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
    base_column_name: []const u8,
    base_table_name: []const u8,
    catalog_name: []const u8,
    label: []const u8,
    literal_prefix: []const u8,
    literal_suffix: []const u8,
    local_type_name: []const u8,
    name: []const u8,
    schema_name: []const u8,
    table_name: []const u8,
    type_name: []const u8,
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

    const Nullable = enum(i64) {
        nullable = c.SQL_NULLABLE,
        no_nulls = c.SQL_NO_NULLS,
        nullable_unknown = c.SQL_NULLABLE_UNKNOWN,
    };
    const NumPrecRadix = enum(i64) {
        approximate_numeric = 2,
        exact_numeric = 10,
        non_numeric = 0,
    };
    const Searchable = enum(i64) {
        unsearchable = c.SQL_PRED_NONE,
        searchable_like_only = c.SQL_PRED_CHAR,
        searchable_no_like = c.SQL_PRED_BASIC,
        searchable = c.SQL_PRED_SEARCHABLE,
    };
    const Unnamed = enum(i64) {
        named = c.SQL_NAMED,
        unnamed = c.SQL_UNNAMED,
    };
    const Updatable = enum(i64) {
        read_only = c.SQL_ATTR_READONLY,
        write = c.SQL_ATTR_WRITE,
        unknown = c.SQL_ATTR_READWRITE_UNKNOWN,
    };

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

//
// Descriptors
//

pub const DescFieldI16 = enum(u15) {
    alloc_type = c.SQL_DESC_ALLOC_TYPE, // ARD: R APD: R IRD: R IPD: R
    count = c.SQL_DESC_COUNT, // ARD: R/W APD: R/W IRD: R IPD: R/W
    concise_type = c.SQL_DESC_CONCISE_TYPE, // ARD: R/W APD: R/W IRD: R IPD: R/W
    datetime_interval_code = c.SQL_DESC_DATETIME_INTERVAL_CODE, // ARD: R/W APD: R/W IRD: R IPD: R/W
    fixed_prec_scale = c.SQL_DESC_FIXED_PREC_SCALE, // ARD: Unused APD: Unused IRD: R IPD: R
    nullable = c.SQL_DESC_NULLABLE, // ARD: Unused APD: Unused IRD: R IPD: R
    parameter_type = c.SQL_DESC_PARAMETER_TYPE, // ARD: Unused APD: Unused IRD: Unused IPD: R/W
    precision = c.SQL_DESC_PRECISION, // ARD: R/W APD: R/W IRD: R IPD: R/W
    rowver = c.SQL_DESC_ROWVER, // ARD: Unused
    scale = c.SQL_DESC_SCALE, // ARD: R/W APD: R/W IRD: R IPD: R/W
    searchable = c.SQL_DESC_SEARCHABLE, // ARD: Unused APD: Unused IRD: R IPD: Unused
    type = c.SQL_DESC_TYPE, // ARD: R/W APD: R/W IRD: R IPD: R/W
    unnamed = c.SQL_DESC_UNNAMED, // ARD: Unused APD: Unused IRD: R IPD: R/W
    unsigned = c.SQL_DESC_UNSIGNED, // ARD: Unused APD: Unused IRD: R IPD: R
    updatable = c.SQL_DESC_UPDATABLE, // ARD: Unused APD: Unused IRD: R IPD: Unused
};

pub const DescFieldU64 = enum(u15) {
    array_size = c.SQL_DESC_ARRAY_SIZE, // ARD: R/W APD: R/W IRD: Unused IPD: Unused
    length = c.SQL_DESC_LENGTH, // ARD: R/W APD: R/W IRD: R IPD: R/W
};

pub const DescFieldMisc = enum(u15) {
    indicator_ptr = c.SQL_DESC_INDICATOR_PTR, // ARD: R/W APD: R/W IRD: Unused IPD: Unused
    data_ptr = c.SQL_DESC_DATA_PTR, // ARD: R/W APD: R/W IRD: Unused IPD: Unused
    octet_length_ptr = c.SQL_DESC_OCTET_LENGTH_PTR, // ARD: R/W APD: R/W IRD: Unused IPD: Unused
};

pub const DescFieldI64 = enum(u15) {
    display_size = c.SQL_DESC_DISPLAY_SIZE, // ARD: Unused APD: Unused IRD: R IPD: Unused
    octet_length = c.SQL_DESC_OCTET_LENGTH, // ARD: R/W APD: R/W IRD: R IPD: R/W
};

// TODO
// SQL_DESC_ARRAY_STATUS_PTR                       SQLUSMALLINT *  ARD: R/W APD: R/W IRD: R/W IPD: R/W
// SQL_DESC_BIND_OFFSET_PTR                        SQLLEN *        ARD: R/W APD: R/W IRD: Unused IPD: Unused
// SQL_DESC_BIND_TYPE                              SQLINTEGER      ARD: R/W APD: R/W IRD: Unused IPD: Unused
// SQL_DESC_ROWS_PROCESSED_PTR                     SQLULEN *       ARD: Unused APD: Unused IRD: R/W IPD: R/W
// SQL_DESC_AUTO_UNIQUE_VALUE                      SQLINTEGER      ARD: Unused APD: Unused IRD: R IPD: Unused
// SQL_DESC_BASE_COLUMN_NAME                       SQLCHAR *       ARD: Unused APD: Unused IRD: R IPD: Unused
// SQL_DESC_BASE_TABLE_NAME                        SQLCHAR *       ARD: Unused APD: Unused IRD: R IPD: Unused
// SQL_DESC_CASE_SENSITIVE                         SQLINTEGER      ARD: Unused APD: Unused IRD: R IPD: R
// SQL_DESC_CATALOG_NAME                           SQLCHAR *       ARD: Unused APD: Unused IRD: R IPD: Unused
// SQL_DESC_DATETIME_INTERVAL_PRECISION            SQLINTEGER      ARD: R/W APD: R/W IRD: R IPD: R/W
// SQL_DESC_LABEL                                  SQLCHAR *       ARD: Unused APD: Unused IRD: R IPD: Unused
// SQL_DESC_LITERAL_PREFIX                         SQLCHAR *       ARD: Unused APD: Unused IRD: R IPD: Unused
// SQL_DESC_LITERAL_SUFFIX                         SQLCHAR *       ARD: Unused APD: Unused IRD: R IPD: Unused
// SQL_DESC_LOCAL_TYPE_NAME                        SQLCHAR *       ARD: Unused APD: Unused IRD: R IPD: R
// SQL_DESC_NAME                                   SQLCHAR *       ARD: Unused APD: Unused IRD: R IPD: R/W
// SQL_DESC_NUM_PREC_RADIX                         SQLINTEGER      ARD: R/W APD: R/W IRD: R IPD: R/W
// SQL_DESC_OCTET_LENGTH_PTR                       SQLLEN *        ARD: R/W APD: R/W IRD: Unused IPD: Unused
// SQL_DESC_SCHEMA_NAME                            SQLCHAR *       ARD: Unused APD: Unused IRD: R IPD: Unused
// SQL_DESC_TABLE_NAME                             SQLCHAR *       ARD: Unused APD: Unused IRD: R IPD: Unused
// SQL_DESC_TYPE_NAME                              SQLCHAR *       ARD: Unused APD: Unused IRD: R IPD: R
