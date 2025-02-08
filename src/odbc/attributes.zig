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
    OdbcVersion = c.SQL_ATTR_ODBC_VERSION,
    OutputNts = c.SQL_ATTR_OUTPUT_NTS,
    ConnectionPooling = c.SQL_ATTR_CONNECTION_POOLING,
    CpMatch = c.SQL_ATTR_CP_MATCH,
    // unixODBC additions
    UnixodbcSyspath = c.SQL_ATTR_UNIXODBC_SYSPATH,
    UnixodbcVersion = c.SQL_ATTR_UNIXODBC_VERSION,
    UnixodbcEnvattr = c.SQL_ATTR_UNIXODBC_ENVATTR,
    // IBM Db2 specific additions
    // - https://www.ibm.com/docs/en/db2-for-zos/11?topic=functions-sqlsetenvattr-set-environment-attributes
    // InfoAcctstr = c.SQL_ATTR_INFO_ACCTSTR,
    // InfoApplname = c.SQL_ATTR_INFO_APPLNAME,
    // InfoUserid = c.SQL_ATTR_INFO_USERID,
    // InfoWrkstnname = c.SQL_ATTR_INFO_WRKSTNNAME,
    // InfoConnecttype = c.SQL_ATTR_INFO_CONNECTTYPE,
    // InfoMaxconn = c.SQL_ATTR_INFO_MAXCONN,
};

pub const EnvironmentAttributeValue = union(EnvironmentAttribute) {
    OdbcVersion: OdbcVersion,
    OutputNts: OutputNts,
    ConnectionPooling: ConnectionPooling,
    CpMatch: CpMatch,
    UnixodbcSyspath: []const u8,
    UnixodbcVersion: []const u8,
    UnixodbcEnvattr: []const u8,

    pub fn init(
        allocator: std.mem.Allocator,
        attr: EnvironmentAttribute,
        odbc_buf: []u8,
        str_len: i32,
    ) !EnvironmentAttributeValue {
        return switch (attr) {
            .OdbcVersion => .{ .OdbcVersion = @enumFromInt(readInt(u32, odbc_buf)) },
            .ConnectionPooling => .{ .ConnectionPooling = @enumFromInt(readInt(u32, odbc_buf)) },
            .CpMatch => .{ .CpMatch = @enumFromInt(readInt(u32, odbc_buf)) },
            .OutputNts => .{ .OutputNts = @enumFromInt(readInt(u32, odbc_buf)) },
            .UnixodbcSyspath => {
                const str = try allocator.alloc(u8, @intCast(str_len));
                @memcpy(str, odbc_buf[0..@intCast(str_len)]);
                return .{ .UnixodbcSyspath = str[0..] };
            },
            .UnixodbcVersion => {
                const str = try allocator.alloc(u8, @intCast(str_len));
                @memcpy(str, odbc_buf[0..@intCast(str_len)]);
                return .{ .UnixodbcVersion = str[0..] };
            },
            .UnixodbcEnvattr => {
                const str = try allocator.alloc(u8, @intCast(str_len));
                @memcpy(str, odbc_buf[0..@intCast(str_len)]);
                return .{ .UnixodbcEnvattr = str[0..] };
            },
        };
    }

    pub fn deinit(
        self: EnvironmentAttributeValue,
        allocator: std.mem.Allocator,
    ) void {
        return switch (self) {
            .OdbcVersion, .ConnectionPooling, .CpMatch, .OutputNts => {},
            .UnixodbcSyspath => |v| allocator.free(v),
            .UnixodbcVersion => |v| allocator.free(v),
            .UnixodbcEnvattr => |v| allocator.free(v),
        };
    }

    pub fn getActiveTag(self: EnvironmentAttributeValue) EnvironmentAttribute {
        return std.meta.activeTag(self);
    }

    pub fn getValue(self: EnvironmentAttributeValue) *allowzero anyopaque {
        return switch (self) {
            .OdbcVersion => |v| @ptrFromInt(@as(usize, @intFromEnum(v))),
            .ConnectionPooling => |v| @ptrFromInt(@as(usize, @intFromEnum(v))),
            .CpMatch => |v| @ptrFromInt(@as(usize, @intFromEnum(v))),
            .OutputNts => |v| @ptrFromInt(@as(usize, @intCast(@intFromEnum(v)))),
            .UnixodbcSyspath, .UnixodbcVersion, .UnixodbcEnvattr => |v| @ptrCast(@constCast(v)),
        };
    }

    pub fn getStrLen(self: EnvironmentAttributeValue) i32 {
        return switch (self) {
            .OdbcVersion, .OutputNts, .ConnectionPooling, .CpMatch => 0,
            .UnixodbcSyspath, .UnixodbcVersion, .UnixodbcEnvattr => |v| @intCast(v.len),
        };
    }

    pub const OdbcVersion = enum(c_ulong) {
        V2 = c.SQL_OV_ODBC2,
        V3 = c.SQL_OV_ODBC3,
        V3_80 = c.SQL_OV_ODBC3_80,
    };

    pub const OutputNts = enum(c_int) {
        True = c.SQL_TRUE,
        False = c.SQL_FALSE,
    };

    pub const ConnectionPooling = enum(c_ulong) {
        Off = c.SQL_CP_OFF,
        OnePerDriver = c.SQL_CP_ONE_PER_DRIVER,
        OnePerHenv = c.SQL_CP_ONE_PER_HENV,
    };

    pub const CpMatch = enum(c_ulong) {
        StrictMatch = c.SQL_CP_STRICT_MATCH,
        RelaxedMatch = c.SQL_CP_RELAXED_MATCH,
    };
};

//
// Connection
//

/// The integer codes for ODBC compliant connection attributes
pub const ConnectionAttribute = enum(c_int) {
    // ODBC spec
    ConnectionDead = c.SQL_ATTR_CONNECTION_DEAD,
    DriverThreading = c.SQL_ATTR_DRIVER_THREADING,
    // ODBC spec >= 3.0
    AccessMode = c.SQL_ATTR_ACCESS_MODE,
    Autocommit = c.SQL_ATTR_AUTOCOMMIT,
    ConnectionTimeout = c.SQL_ATTR_CONNECTION_TIMEOUT,
    // CurrentCatalog = c.SQL_ATTR_CURRENT_CATALOG,
    DisconnectBehavior = c.SQL_ATTR_DISCONNECT_BEHAVIOR,
    EnlistInDtc = c.SQL_ATTR_ENLIST_IN_DTC,
    // EnlistInXa = c.SQL_ATTR_ENLIST_IN_XA,
    LoginTimeout = c.SQL_ATTR_LOGIN_TIMEOUT,
    OdbcCursors = c.SQL_ATTR_ODBC_CURSORS,
    PacketSize = c.SQL_ATTR_PACKET_SIZE,
    // QuietMode = c.SQL_ATTR_QUIET_MODE,
    Trace = c.SQL_ATTR_TRACE,
    // TraceFile = c.SQL_ATTR_TRACEFILE,
    // TranslateLib = c.SQL_ATTR_TRANSLATE_LIB,
    // TranslateOption = c.SQL_ATTR_TRANSLATE_OPTION,
    TxnIsolation = c.SQL_ATTR_TXN_ISOLATION,
    // ODBC spec >= 3.51
    AnsiApp = c.SQL_ATTR_ANSI_APP,
    AsyncEnable = c.SQL_ATTR_ASYNC_ENABLE,
    AutoIpd = c.SQL_ATTR_AUTO_IPD,
    // ODBC spec >= 3.80
    ResetConnection = c.SQL_ATTR_RESET_CONNECTION,
    AsyncDbcFunctionsEnable = c.SQL_ATTR_ASYNC_DBC_FUNCTIONS_ENABLE,
    // Not sure what this group should be?
    // IBM Db2 specific additions
    // - https://www.ibm.com/docs/en/db2-for-zos/13?topic=functions-sqlsetconnectattr-set-connection-attributes
    // https://github.com/strongloop-forks/node-ibm_db/blob/master/deps/db2cli/include/sqlcli1.h#L690
    // ClientTimeZone = c.SQL_ATTR_CLIENT_TIME_ZONE,
    // ConcurrentAccessResolution = c.SQL_ATTR_CONCURRENT_ACCESS_RESOLUTION,
    // Connecttype = c.SQL_ATTR_CONNECTTYPE,
    // CurrentSchema = c.SQL_ATTR_CURRENT_SCHEMA,
    // Db2Explain = c.SQL_ATTR_DB2_EXPLAIN,
    // DecfloatRoundingMode = c.SQL_ATTR_DECFLOAT_ROUNDING_MODE,
    // ExtendedIndicators = c.SQL_ATTR_EXTENDED_INDICATORS,
    // InfoAcctstr = c.SQL_ATTR_INFO_ACCTSTR,
    // InfoApplname = c.SQL_ATTR_INFO_APPLNAME,
    // InfoUserid = c.SQL_ATTR_INFO_USERID,
    // InfoWrkstnname = c.SQL_ATTR_INFO_WRKSTNNAME,
    // KeepDynamic = c.SQL_ATTR_KEEP_DYNAMIC,
    // Maxconn = c.SQL_ATTR_MAXCONN,
    // MetadataId = c.SQL_ATTR_METADATA_ID,
    // SessionTimeZone = c.SQL_ATTR_SESSION_TIME_ZONE,
    // SyncPoint = c.SQL_ATTR_SYNC_POINT,
    // FetBufSize = c.SQL_ATTR_FET_BUF_SIZE,
    FetBufSize = 3001,
};

pub const ConnectionAttributeValue = union(ConnectionAttribute) {
    ConnectionDead: ConnectionDead,
    DriverThreading: u16,
    AccessMode: AccessMode,
    Autocommit: Autocommit,
    ConnectionTimeout: u32,
    // CurrentCatalog: CurrentCatalog,
    DisconnectBehavior: DisconnectBehavior,
    EnlistInDtc: EnlistInDtc,
    // EnlistInXa: EnlistInXa,
    LoginTimeout: u32,
    OdbcCursors: OdbcCursors,
    PacketSize: u32,
    // QuietMode: QuietMode,
    Trace: Trace,
    // TraceFile: []const u8,
    // TranslateLib: []const u8,
    // TranslateOption: []const u8,
    TxnIsolation: TxnIsolation,
    AnsiApp: AnsiApp,
    AsyncEnable: AsyncEnable,
    AutoIpd: AutoIpd,
    ResetConnection: ResetConnection,
    AsyncDbcFunctionsEnable: AsyncDbcFunctionsEnable,
    FetBufSize: u32,

    pub fn init(
        allocator: std.mem.Allocator,
        attr: ConnectionAttribute,
        odbc_buf: []u8,
        str_len: i32,
    ) !ConnectionAttributeValue {
        _ = str_len;
        _ = allocator;
        return switch (attr) {
            .ConnectionDead => .{ .ConnectionDead = @enumFromInt(readInt(i64, odbc_buf)) },
            .DriverThreading => .{ .DriverThreading = readInt(u16, odbc_buf) },
            .AccessMode => .{ .AccessMode = @enumFromInt(readInt(i32, odbc_buf)) },
            .Autocommit => .{ .Autocommit = @enumFromInt(readInt(u64, odbc_buf)) },
            .ConnectionTimeout => .{ .ConnectionTimeout = readInt(u32, odbc_buf) },
            // .CurrentCatalog => .{ .CurrentCatalog = readInt(u32, odbc_buf) },
            .DisconnectBehavior => .{ .TxnIsolation = @enumFromInt(readInt(i64, odbc_buf)) },
            .EnlistInDtc => .{ .EnlistInDtc = @enumFromInt(readInt(u32, odbc_buf)) },
            // .EnlistInXa => .{ .EnlistInXa = @enumFromInt(readInt(u32, odbc_buf)) },
            .LoginTimeout => .{ .LoginTimeout = readInt(u32, odbc_buf) },
            .OdbcCursors => .{ .OdbcCursors = @enumFromInt(readInt(u32, odbc_buf)) },
            .PacketSize => .{ .PacketSize = readInt(u32, odbc_buf) },
            // .QuietMode => .{ .QuietMode = readInt(u32, odbc_buf) },
            .Trace => .{ .Trace = @enumFromInt(readInt(u32, odbc_buf)) },
            // .TraceFile => {
            //     const str = try allocator.alloc(u8, @intCast(str_len));
            //     @memcpy(str, odbc_buf[0..@intCast(str_len)]);
            //     return .{ .TraceFile = str[0..] };
            // },
            // .TranslateLib => {
            //     const str = try allocator.alloc(u8, @intCast(str_len));
            //     @memcpy(str, odbc_buf[0..@intCast(str_len)]);
            //     return .{ .TranslateLib = str[0..] };
            // },
            // .TranslateOption => {
            //     const str = try allocator.alloc(u8, @intCast(str_len));
            //     @memcpy(str, odbc_buf[0..@intCast(str_len)]);
            //     return .{ .TranslateOption = str[0..] };
            // },
            .TxnIsolation => .{ .TxnIsolation = @enumFromInt(readInt(u32, odbc_buf)) },
            .AnsiApp => .{ .AnsiApp = @enumFromInt(readInt(u32, odbc_buf)) },
            .AsyncEnable => .{ .AsyncEnable = @enumFromInt(readInt(u32, odbc_buf)) },
            .AutoIpd => .{ .AutoIpd = @enumFromInt(readInt(u32, odbc_buf)) },
            .ResetConnection => .{ .ResetConnection = @enumFromInt(readInt(u32, odbc_buf)) },
            .AsyncDbcFunctionsEnable => .{ .AsyncDbcFunctionsEnable = @enumFromInt(readInt(u32, odbc_buf)) },
            .FetBufSize => .{ .FetBufSize = readInt(u32, odbc_buf) },
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
            // .UnixodbcSyspath, .UnixodbcVersion, .UnixodbcEnvattr => |v| @ptrCast(@constCast(v)),
            .ConnectionDead => |v| @ptrFromInt(@as(usize, @intCast(@intFromEnum(v)))),
            .DriverThreading => |v| @ptrFromInt(@as(usize, v)),
            .AccessMode => |v| @ptrFromInt(@as(usize, @intCast(@intFromEnum(v)))),
            .Autocommit => |v| @ptrFromInt(@as(usize, @intFromEnum(v))),
            .ConnectionTimeout => |v| @ptrFromInt(@as(usize, v)),
            .DisconnectBehavior => |v| @ptrFromInt(@as(usize, @intFromEnum(v))),
            .EnlistInDtc => |v| @ptrFromInt(@as(usize, @intCast(@intFromEnum(v)))),
            // .EnlisttInXa => |v| @ptrFromInt(@as(usize, @intFromEnum(v))),
            .LoginTimeout => |v| @ptrFromInt(@as(usize, v)),
            .OdbcCursors => |v| @ptrFromInt(@as(usize, @intFromEnum(v))),
            .PacketSize => |v| @ptrFromInt(@as(usize, v)),
            // .QuietMode => |v| @ptrFromInt(@as(usize, v)),
            .Trace => |v| @ptrFromInt(@as(usize, @intFromEnum(v))),
            .TxnIsolation => |v| @ptrFromInt(@as(usize, @intCast(@intFromEnum(v)))),
            .AnsiApp => |v| @ptrFromInt(@as(usize, @intCast(@intFromEnum(v)))),
            .AsyncEnable => |v| @ptrFromInt(@as(usize, @intFromEnum(v))),
            .AutoIpd => |v| @ptrFromInt(@as(usize, @intCast(@intFromEnum(v)))),
            .ResetConnection => |v| @ptrFromInt(@as(usize, @intFromEnum(v))),
            .AsyncDbcFunctionsEnable => |v| @ptrFromInt(@as(usize, @intCast(@intFromEnum(v)))),
            .FetBufSize => |v| @ptrFromInt(@as(usize, v)),
        };
    }

    pub fn getStrLen(self: ConnectionAttributeValue) i32 {
        return switch (self) {
            .ConnectionDead,
            .DriverThreading,
            .AccessMode,
            .Autocommit,
            .ConnectionTimeout,
            .DisconnectBehavior,
            .EnlistInDtc,
            // .EnlisttInXa,
            .LoginTimeout,
            .OdbcCursors,
            .PacketSize,
            // .QuietMode,
            .Trace,
            .TxnIsolation,
            .AnsiApp,
            .AutoIpd,
            .ResetConnection,
            .AsyncDbcFunctionsEnable,
            .FetBufSize,
            => 0,
            // .CurrentCatalog, .TraceFile, .TranslateLib, .TranslateOption => |v| @intCast(v.len),
            else => 1,
        };
    }

    pub const ConnectionDead = enum(c_long) {
        True = c.SQL_CD_TRUE,
        False = c.SQL_CD_FALSE,
    };

    pub const AccessMode = enum(c_int) {
        ReadWrite = c.SQL_MODE_READ_WRITE,
        ReadOnly = c.SQL_MODE_READ_ONLY,
    };

    pub const Autocommit = enum(c_ulong) {
        Off = c.SQL_AUTOCOMMIT_OFF,
        On = c.SQL_AUTOCOMMIT_ON,
    };

    pub const DisconnectBehavior = enum(c_ulong) {
        ReturnToPool = c.SQL_DB_RETURN_TO_POOL,
        Disconnect = c.SQL_DB_DISCONNECT,
    };

    pub const EnlistInDtc = enum(c_long) {
        EnlistExpensive = c.SQL_DTC_ENLIST_EXPENSIVE,
        UnenlistExpensive = c.SQL_DTC_UNENLIST_EXPENSIVE,
    };

    pub const OdbcCursors = enum(c_ulong) {
        IfNeeded = c.SQL_CUR_USE_IF_NEEDED,
        UseOdbc = c.SQL_CUR_USE_ODBC,
        UseDriver = c.SQL_CUR_USE_DRIVER,
    };

    pub const Trace = enum(c_ulong) {
        Off = c.SQL_OPT_TRACE_OFF,
        On = c.SQL_OPT_TRACE_ON,
    };

    pub const TxnIsolation = enum(c_long) {
        ReadUncommitted = c.SQL_TXN_READ_UNCOMMITTED,
        ReadCommitted = c.SQL_TRANSACTION_READ_COMMITTED,
        RepeatableRead = c.SQL_TXN_REPEATABLE_READ,
        Serializable = c.SQL_TXN_SERIALIZABLE,
    };

    pub const AnsiApp = enum(c_long) {
        True = c.SQL_AA_TRUE,
        False = c.SQL_AA_FALSE,
    };

    pub const AsyncEnable = enum(c_ulong) {
        Off = c.SQL_ASYNC_ENABLE_OFF,
        On = c.SQL_ASYNC_ENABLE_ON,
    };

    pub const AutoIpd = enum(c_int) {
        True = c.SQL_TRUE,
        False = c.SQL_FALSE,
    };

    pub const ResetConnection = enum(c_ulong) {
        Yes = c.SQL_RESET_CONNECTION_YES,
    };

    pub const AsyncDbcFunctionsEnable = enum(c_int) {
        On = c.SQL_ASYNC_DBC_ENABLE_ON,
        Off = c.SQL_ASYNC_DBC_ENABLE_OFF,
    };
};

//
// Column
//

/// The integer codes for ODBC compliant column attributes
pub const ColAttributeCharacter = enum(c_ushort) {
    BaseColumnName = c.SQL_DESC_BASE_COLUMN_NAME, // (ODBC 3.0)	CharacterAttributePtr	The base column name for the result set column. If a base column name does not exist (as in the case of columns that are expressions), then this variable contains an empty string.
    BaseTableName = c.SQL_DESC_BASE_TABLE_NAME, // (ODBC 3.0)	CharacterAttributePtr	The name of the base table that contains the column. If the base table name cannot be defined or is not applicable, then this variable contains an empty string.
    CatalogName = c.SQL_DESC_CATALOG_NAME, // (ODBC 2.0)	CharacterAttributePtr	The catalog of the table that contains the column. The returned value is implementation-defined if the column is an expression or if the column is part of a view. If the data source does not support catalogs or the catalog name cannot be determined, an empty string is returned. This VARCHAR record field is not limited to 128 characters.
    Label = c.SQL_DESC_LABEL, // (ODBC 2.0)	CharacterAttributePtr	The column label or title. For example, a column named EmpName might be labeled Employee Name or might be labeled with an alias.
    LiteralPrefix = c.SQL_DESC_LITERAL_PREFIX, // (ODBC 3.0)	CharacterAttributePtr	This VARCHAR(128) record field contains the character or characters that the driver recognizes as a prefix for a literal of this data type. This field contains an empty string for a data type for which a literal prefix is not applicable. For more information, see Literal Prefixes and Suffixes.
    LiteralSuffix = c.SQL_DESC_LITERAL_SUFFIX, // (ODBC 3.0)	CharacterAttributePtr	This VARCHAR(128) record field contains the character or characters that the driver recognizes as a suffix for a literal of this data type. This field contains an empty string for a data type for which a literal suffix is not applicable. For more information, see Literal Prefixes and Suffixes.
    LocalTypeName = c.SQL_DESC_LOCAL_TYPE_NAME, // (ODBC 3.0)	CharacterAttributePtr	This VARCHAR(128) record field contains any localized (native language) name for the data type that may be different from the regular name of the data type. If there is no localized name, then an empty string is returned. This field is for display purposes only. The character set of the string is locale-dependent and is typically the default character set of the server.
    Name = c.SQL_DESC_NAME, // (ODBC 3.0)	CharacterAttributePtr	The column alias, if it applies. If the column alias does not apply, the column name is returned. In either case, SQL_DESC_UNNAMED is set to SQL_NAMED. If there is no column name or a column alias, an empty string is returned and SQL_DESC_UNNAMED is set to SQL_UNNAMED.
    SchemaName = c.SQL_DESC_SCHEMA_NAME, // (ODBC 2.0)	CharacterAttributePtr	The schema of the table that contains the column. The returned value is implementation-defined if the column is an expression or if the column is part of a view. If the data source does not support schemas or the schema name cannot be determined, an empty string is returned. This VARCHAR record field is not limited to 128 characters.
    TableName = c.SQL_DESC_TABLE_NAME, // (ODBC 2.0)	CharacterAttributePtr	The name of the table that contains the column. The returned value is implementation-defined if the column is an expression or if the column is part of a view.
    TypeName = c.SQL_DESC_TYPE_NAME, // (ODBC 1.0)	CharacterAttributePtr	Data source-dependent data type name; for example, "CHAR", "VARCHAR", "MONEY", "LONG VARBINARY", or "CHAR ( ) FOR BIT DATA".
};

pub const ColAttribute = enum(c_ushort) {
    AutoUniqueValue = c.SQL_DESC_AUTO_UNIQUE_VALUE, // (ODBC 1.0)	NumericAttributePtr	SQL_TRUE if the column is an autoincrementing column.
    CaseSensitive = c.SQL_DESC_CASE_SENSITIVE, // (ODBC 1.0)	NumericAttributePtr	SQL_TRUE if the column is treated as case-sensitive for collations and comparisons.
    ConciseType = c.SQL_DESC_CONCISE_TYPE, // (ODBC 1.0)	NumericAttributePtr	The concise data type.
    Count = c.SQL_DESC_COUNT, // (ODBC 1.0)	NumericAttributePtr	The number of columns available in the result set. This returns 0 if there are no columns in the result set. The value in the ColumnNumber argument is ignored.
    DisplaySize = c.SQL_DESC_DISPLAY_SIZE, // (ODBC 1.0)	NumericAttributePtr	Maximum number of characters required to display data from the column. For more information about display size, see Column Size, Decimal Digits, Transfer Octet Length, and Display Size in Appendix D: Data Types.
    FixedPrecScale = c.SQL_DESC_FIXED_PREC_SCALE, // (ODBC 1.0)	NumericAttributePtr	SQL_TRUE if the column has a fixed precision and nonzero scale that are data source-specific.
    Length = c.SQL_DESC_LENGTH, // (ODBC 3.0)	NumericAttributePtr	A numeric value that is either the maximum or actual character length of a character string or binary data type. It is the maximum character length for a fixed-length data type, or the actual character length for a variable-length data type. Its value always excludes the null-termination byte that ends the character string.
    Nullable = c.SQL_DESC_NULLABLE, // (ODBC 3.0)	NumericAttributePtr	SQL_ NULLABLE if the column can have NULL values; SQL_NO_NULLS if the column does not have NULL values; or SQL_NULLABLE_UNKNOWN if it is not known whether the column accepts NULL values.
    NumPrecRadix = c.SQL_DESC_NUM_PREC_RADIX, // (ODBC 3.0)	NumericAttributePtr	If the data type in the SQL_DESC_TYPE field is an approximate numeric data type, this SQLINTEGER field contains a value of 2 because the SQL_DESC_PRECISION field contains the number of bits. If the data type in the SQL_DESC_TYPE field is an exact numeric data type, this field contains a value of 10 because the SQL_DESC_PRECISION field contains the number of decimal digits. This field is set to 0 for all non-numeric data types.
    OctetLength = c.SQL_DESC_OCTET_LENGTH, // (ODBC 3.0)	NumericAttributePtr	The length, in bytes, of a character string or binary data type. For fixed-length character or binary types, this is the actual length in bytes. For variable-length character or binary types, this is the maximum length in bytes. This value does not include the null terminator.
    Precision = c.SQL_DESC_PRECISION, // (ODBC 3.0)	NumericAttributePtr	A numeric value that for a numeric data type denotes the applicable precision. For data types SQL_TYPE_TIME, SQL_TYPE_TIMESTAMP, and all the interval data types that represent a time interval, its value is the applicable precision of the fractional seconds component.
    Scale = c.SQL_DESC_SCALE, // (ODBC 3.0)	NumericAttributePtr	A numeric value that is the applicable scale for a numeric data type. For DECIMAL and NUMERIC data types, this is the defined scale. It is undefined for all other data types.
    Searchable = c.SQL_DESC_SEARCHABLE, // (ODBC 1.0)	NumericAttributePtr	SQL_PRED_NONE if the column cannot be used in a WHERE clause. (This is the same as the SQL_UNSEARCHABLE value in ODBC 2.x.)
    Type = c.SQL_DESC_TYPE, // (ODBC 3.0)	NumericAttributePtr	A numeric value that specifies the SQL data type.
    Unnamed = c.SQL_DESC_UNNAMED, // (ODBC 3.0)	NumericAttributePtr	SQL_NAMED or SQL_UNNAMED. If the SQL_DESC_NAME field of the IRD contains a column alias or a column name, SQL_NAMED is returned. If there is no column name or column alias, SQL_UNNAMED is returned.
    Unsigned = c.SQL_DESC_UNSIGNED, // (ODBC 1.0)	NumericAttributePtr	SQL_TRUE if the column is unsigned (or not numeric).
    Updatable = c.SQL_DESC_UPDATABLE, // (ODBC 1.0)	NumericAttributePtr	Column is described by the values for the defined constants:
};

pub const ColAttributeValue = union(ColAttribute) {
    AutoUniqueValue: c_long,
    CaseSensitive: c_long,
    ConciseType: types.SQLDataType,
    Count: c_long,
    DisplaySize: c_long,
    FixedPrecScale: c_long,
    Length: c_long,
    Nullable: c_long,
    NumPrecRadix: c_long,
    OctetLength: c_long,
    Precision: c_long,
    Scale: c_long,
    Searchable: c_long,
    Type: types.SQLDataType,
    Unnamed: c_long,
    Unsigned: c_long,
    Updatable: c_long,

    pub fn init(
        attr: ColAttribute,
        num_val: c_long,
    ) !ColAttributeValue {
        std.debug.print("{}\n", .{num_val});
        // TODO @unionInit
        switch (attr) {
            .Type => return .{ .Type = @enumFromInt(num_val) },
            .ConciseType => return .{ .ConciseType = @enumFromInt(num_val) },
            else => unreachable,
        }
    }
};
