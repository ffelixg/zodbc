const std = @import("std");
const c = @import("c");
const msodbcsql_h = @import("root.zig").msodbcsql_h;

pub const HandleType = enum(c_short) {
    ENV = c.SQL_HANDLE_ENV,
    DBC = c.SQL_HANDLE_DBC,
    STMT = c.SQL_HANDLE_STMT,
    DESC = c.SQL_HANDLE_DESC,
};

pub const SetStatementAttrAttribute = enum(c_int) {
    // Statement attributes for ODBC 3.0
    ASYNC_ENABLE = c.SQL_ATTR_ASYNC_ENABLE,
    CONCURRENCY = c.SQL_ATTR_CONCURRENCY,
    CURSOR_TYPE = c.SQL_ATTR_CURSOR_TYPE,
    ENABLE_AUTO_IPD = c.SQL_ATTR_ENABLE_AUTO_IPD,
    FETCH_BOOKMARK_PTR = c.SQL_ATTR_FETCH_BOOKMARK_PTR,
    KEYSET_SIZE = c.SQL_ATTR_KEYSET_SIZE,
    MAX_LENGTH = c.SQL_ATTR_MAX_LENGTH,
    MAX_ROWS = c.SQL_ATTR_MAX_ROWS,
    NOSCAN = c.SQL_ATTR_NOSCAN,
    PARAM_BIND_OFFSET_PTR = c.SQL_ATTR_PARAM_BIND_OFFSET_PTR,
    PARAM_BIND_TYPE = c.SQL_ATTR_PARAM_BIND_TYPE,
    PARAM_OPERATION_PTR = c.SQL_ATTR_PARAM_OPERATION_PTR,
    PARAM_STATUS_PTR = c.SQL_ATTR_PARAM_STATUS_PTR,
    PARAMS_PROCESSED_PTR = c.SQL_ATTR_PARAMS_PROCESSED_PTR,
    PARAMSET_SIZE = c.SQL_ATTR_PARAMSET_SIZE,
    QUERY_TIMEOUT = c.SQL_ATTR_QUERY_TIMEOUT,
    RETRIEVE_DATA = c.SQL_ATTR_RETRIEVE_DATA,
    ROW_BIND_OFFSET_PTR = c.SQL_ATTR_ROW_BIND_OFFSET_PTR,
    ROW_BIND_TYPE = c.SQL_ATTR_ROW_BIND_TYPE,
    ROW_NUMBER = c.SQL_ATTR_ROW_NUMBER,
    ROW_OPERATION_PTR = c.SQL_ATTR_ROW_OPERATION_PTR,
    ROW_STATUS_PTR = c.SQL_ATTR_ROW_STATUS_PTR,
    ROWS_FETCHED_PTR = c.SQL_ATTR_ROWS_FETCHED_PTR,
    ROW_ARRAY_SIZE = c.SQL_ATTR_ROW_ARRAY_SIZE,
    SIMULATE_CURSOR = c.SQL_ATTR_SIMULATE_CURSOR,
    USE_BOOKMARKS = c.SQL_ATTR_USE_BOOKMARKS,
    // Statement attributes for ODBC >= 3.80
    ASYNC_STMT_EVENT = c.SQL_ATTR_ASYNC_STMT_EVENT,
    // TODO:
    // - not sure what this group should be?
    // APP_ROW_DESC = c.SQL_ATTR_APP_ROW_DESC,
    // APP_PARAM_DESC = c.SQL_ATTR_APP_PARAM_DESC,
    // IMP_ROW_DESC = c.SQL_ATTR_IMP_ROW_DESC,
    // IMP_PARAM_DESC = c.SQL_ATTR_IMP_PARAM_DESC,
    // CURSOR_SCROLLABLE = c.SQL_ATTR_CURSOR_SCROLLABLE,
    // CURSOR_SENSITIVITY = c.SQL_ATTR_CURSOR_SENSITIVITY,
};

pub const ColAttributes = enum(c_int) {
    // Subdefines for SQL_COLUMN_UPDATABLE
    READONLY = c.SQL_ATTR_READONLY,
    WRITE = c.SQL_ATTR_WRITE,
    READWRITE_UNKNOWN = c.SQL_ATTR_READWRITE_UNKNOWN,
};

pub const ColDescription = struct {
    allocator: std.mem.Allocator,
    name_buf: []u8,
    name_buf_len: usize,
    data_type: c_short,
    column_size: u32,
    decimal_digits: c_short,
    nullable: c_short,

    pub fn init(allocator: std.mem.Allocator) !ColDescription {
        const name_buf = try allocator.alloc(u8, 256);
        return .{
            .allocator = allocator,
            .name_buf = name_buf,
            .name_buf_len = name_buf.len,
            .data_type = -1,
            .column_size = 0,
            .decimal_digits = -1,
            .nullable = -1,
        };
    }

    pub fn deinit(self: ColDescription) void {
        self.allocator.free(self.name_buf);
    }
};

pub const SQLDataType = enum(i16) {
    // https://learn.microsoft.com/en-us/sql/relational-databases/native-client-odbc-date-time/data-type-support-for-odbc-date-and-time-improvements?view=sql-server-ver15
    // SQL Server types
    ss_timestampoffset = msodbcsql_h(-155, "SQL_SS_TIMESTAMPOFFSET"),
    ss_time2 = msodbcsql_h(-154, "SQL_SS_TIME2"),
    ss_table = msodbcsql_h(-153, "SQL_SS_TABLE"),
    ss_xml = msodbcsql_h(-152, "SQL_SS_XML"),
    ss_udt = msodbcsql_h(-151, "SQL_SS_UDT"),
    ss_variant = msodbcsql_h(-150, "SQL_SS_VARIANT"),

    guid = c.SQL_GUID,
    wlongvarchar = c.SQL_WLONGVARCHAR,
    wvarchar = c.SQL_WVARCHAR,
    wchar = c.SQL_WCHAR,
    bit = c.SQL_BIT,
    tinyint = c.SQL_TINYINT,
    bigint = c.SQL_BIGINT,
    longvarbinary = c.SQL_LONGVARBINARY,
    varbinary = c.SQL_VARBINARY,
    binary = c.SQL_BINARY,
    longvarchar = c.SQL_LONGVARCHAR,
    unknown_type = c.SQL_UNKNOWN_TYPE,
    char = c.SQL_CHAR,
    decimal = c.SQL_DECIMAL,
    numeric = c.SQL_NUMERIC,
    smallint = c.SQL_SMALLINT,
    integer = c.SQL_INTEGER,
    real = c.SQL_REAL,
    float = c.SQL_FLOAT,
    double = c.SQL_DOUBLE,
    datetime = c.SQL_DATETIME, // verbose type
    interval = c.SQL_INTERVAL, // verbose type
    varchar = c.SQL_VARCHAR,

    // https://learn.microsoft.com/en-us/sql/odbc/reference/appendixes/data-type-identifiers-and-descriptors?view=sql-server-ver16
    // Concise types
    type_date = c.SQL_TYPE_DATE,
    type_time = c.SQL_TYPE_TIME,
    type_timestamp = c.SQL_TYPE_TIMESTAMP,
    interval_month = c.SQL_INTERVAL_MONTH,
    interval_year = c.SQL_INTERVAL_YEAR,
    interval_year_to_month = c.SQL_INTERVAL_YEAR_TO_MONTH,
    interval_day = c.SQL_INTERVAL_DAY,
    interval_hour = c.SQL_INTERVAL_HOUR,
    interval_minute = c.SQL_INTERVAL_MINUTE,
    interval_second = c.SQL_INTERVAL_SECOND,
    interval_day_to_hour = c.SQL_INTERVAL_DAY_TO_HOUR,
    interval_day_to_minute = c.SQL_INTERVAL_DAY_TO_MINUTE,
    interval_day_to_second = c.SQL_INTERVAL_DAY_TO_SECOND,
    interval_hour_to_minute = c.SQL_INTERVAL_HOUR_TO_MINUTE,
    interval_hour_to_second = c.SQL_INTERVAL_HOUR_TO_SECOND,
    interval_minute_to_second = c.SQL_INTERVAL_MINUTE_TO_SECOND,
};

pub const Time2 = extern struct {
    hour: c.SQLUSMALLINT,
    minute: c.SQLUSMALLINT,
    second: c.SQLUSMALLINT,
    fraction: c.SQLUINTEGER,
};

pub const TimestampOffset = extern struct {
    year: c.SQLSMALLINT,
    month: c.SQLUSMALLINT,
    day: c.SQLUSMALLINT,
    hour: c.SQLUSMALLINT,
    minute: c.SQLUSMALLINT,
    second: c.SQLUSMALLINT,
    fraction: c.SQLUINTEGER,
    timezone_hour: c.SQLSMALLINT,
    timezone_minute: c.SQLSMALLINT,
};

pub const CDataType = enum(c_short) {
    ss_time2 = msodbcsql_h(0x04000 + 0, "SQL_C_SS_TIME2"),
    ss_timestampoffset = msodbcsql_h(0x04000 + 1, "SQL_C_SS_TIMESTAMPOFFSET"),

    utinyint = c.SQL_C_UTINYINT,
    stinyint = c.SQL_C_STINYINT,
    ubigint = c.SQL_C_UBIGINT,
    sbigint = c.SQL_C_SBIGINT,
    ulong = c.SQL_C_ULONG,
    slong = c.SQL_C_SLONG,
    ushort = c.SQL_C_USHORT,
    sshort = c.SQL_C_SSHORT,
    guid = c.SQL_C_GUID,
    tinyint = c.SQL_C_TINYINT,
    wchar = c.SQL_C_WCHAR,
    bit = c.SQL_C_BIT,
    binary = c.SQL_C_BINARY,

    char = c.SQL_C_CHAR,
    numeric = c.SQL_C_NUMERIC,
    long = c.SQL_C_LONG,
    short = c.SQL_C_SHORT,
    float = c.SQL_C_FLOAT,
    double = c.SQL_C_DOUBLE,
    date = c.SQL_C_DATE,
    time = c.SQL_C_TIME,
    timestamp = c.SQL_C_TIMESTAMP,
    type_date = c.SQL_C_TYPE_DATE,
    type_time = c.SQL_C_TYPE_TIME,
    type_timestamp = c.SQL_C_TYPE_TIMESTAMP,

    default = c.SQL_C_DEFAULT,
    ard_type = c.SQL_ARD_TYPE,

    interval_year = c.SQL_C_INTERVAL_YEAR,
    interval_month = c.SQL_C_INTERVAL_MONTH,
    interval_day = c.SQL_C_INTERVAL_DAY,
    interval_hour = c.SQL_C_INTERVAL_HOUR,
    interval_minute = c.SQL_C_INTERVAL_MINUTE,
    interval_second = c.SQL_C_INTERVAL_SECOND,
    interval_year_to_month = c.SQL_C_INTERVAL_YEAR_TO_MONTH,
    interval_day_to_hour = c.SQL_C_INTERVAL_DAY_TO_HOUR,
    interval_day_to_minute = c.SQL_C_INTERVAL_DAY_TO_MINUTE,
    interval_day_to_second = c.SQL_C_INTERVAL_DAY_TO_SECOND,
    interval_hour_to_minute = c.SQL_C_INTERVAL_HOUR_TO_MINUTE,
    interval_hour_to_second = c.SQL_C_INTERVAL_HOUR_TO_SECOND,
    interval_minute_to_second = c.SQL_C_INTERVAL_MINUTE_TO_SECOND,

    // BOOKMARK = c.SQL_C_BOOKMARK,
    // VARBOOKMARK = c.SQL_C_VARBOOKMARK,
    // TCHAR = c.SQL_C_TCHAR,

    pub fn fromSQL(data_type: c_short) CDataType {
        _ = data_type;
        return .default;
    }

    pub fn MaybeType(fmt: CDataType) ?type {
        return switch (fmt) {
            .char => c.SQLCHAR,
            .wchar => c.SQLWCHAR,
            .sshort => c.SQLSMALLINT,
            .ushort => c.SQLUSMALLINT,
            .slong => c.SQLINTEGER,
            .ulong => c.SQLUINTEGER,
            .float => c.SQLREAL,
            .double => c.SQLDOUBLE,
            .bit => c.SQLCHAR,
            .stinyint => c.SQLSCHAR,
            .utinyint => c.SQLCHAR,
            .sbigint => c.SQLBIGINT,
            .ubigint => c.SQLUBIGINT,
            .binary => c.SQLCHAR,
            .type_date => c.SQL_DATE_STRUCT,
            .type_time => c.SQL_TIME_STRUCT,
            .type_timestamp => c.SQL_TIMESTAMP_STRUCT,
            .numeric => c.SQL_NUMERIC_STRUCT,
            .guid => c.SQLGUID,
            .ss_time2 => Time2,
            .ss_timestampoffset => TimestampOffset,
            else => null,
        };
    }

    pub fn Type(fmt: CDataType) type {
        return fmt.MaybeType() orelse noreturn;
    }

    pub fn asType(comptime fmt: CDataType, data: []u8) if (fmt.MaybeType()) |T| []T else noreturn {
        if (fmt.MaybeType() != null) {
            return @ptrCast(@alignCast(data));
        } else unreachable;
    }

    pub fn asTypeValue(comptime fmt: CDataType, data: []u8) if (fmt.MaybeType()) |T| T else noreturn {
        if (fmt.MaybeType()) |T| {
            return std.mem.bytesToValue(T, data);
        } else unreachable;
    }

    pub fn alloc(fmt: CDataType, allocator: std.mem.Allocator, n: usize) ![]u8 {
        switch (fmt) {
            inline else => |f| {
                if (f.MaybeType()) |T| {
                    return @ptrCast(try allocator.alloc(T, n));
                } else {
                    @panic("unsupported type");
                }
            },
        }
    }

    pub fn free(fmt: CDataType, allocator: std.mem.Allocator, data: []u8) void {
        switch (fmt) {
            inline else => |f| {
                if (f.MaybeType() == null) {
                    @panic("unsupported type");
                }
                allocator.free(f.asType(data));
            },
        }
    }

    pub fn sizeOf(fmt: CDataType) usize {
        switch (fmt) {
            inline else => |f| {
                if (f.MaybeType()) |T| {
                    return @sizeOf(T);
                } else {
                    @panic("unsupported type");
                }
            },
        }
    }
};

pub const Column = struct {
    allocator: std.mem.Allocator,
    c_data_type: CDataType,
    buffer: []u8,
    str_len_or_ind: usize,

    pub fn init(allocator: std.mem.Allocator, col_desc: ColDescription) !Column {
        const buffer = try allocator.alloc(u8, col_desc.column_size);
        return .{
            .allocator = allocator,
            .c_data_type = CDataType.fromSQL(col_desc.data_type),
            .buffer = buffer,
            .str_len_or_ind = 0,
        };
    }

    pub fn deinit(self: Column) void {
        self.allocator.free(self.buffer);
    }
};

pub const FetchOrientation = enum(c_short) {
    NEXT = c.SQL_FETCH_NEXT,
    FIRST = c.SQL_FETCH_FIRST,
    LAST = c.SQL_FETCH_LAST,
    PRIOR = c.SQL_FETCH_PRIOR,
    ABSOLUTE = c.SQL_FETCH_ABSOLUTE,
    RELATIVE = c.SQL_FETCH_RELATIVE,
};
