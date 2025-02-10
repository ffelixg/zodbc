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
