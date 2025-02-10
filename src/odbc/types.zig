const std = @import("std");

pub const c = @cImport({
    @cInclude("sql.h");
    @cInclude("sqltypes.h");
    @cInclude("sqlext.h");
});

pub const msodbc = @cImport({
    @cInclude("sql.h");
    @cInclude("sqltypes.h");
    @cInclude("sqlext.h");
    @cInclude("wchar.h");
    @cInclude("msodbcsql.h");
});

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
    const name_buf_len = 256;

    allocator: std.mem.Allocator,
    name_buf: []u8,
    name_buf_len: usize,
    data_type: c_short,
    column_size: u32,
    decimal_digits: c_short,
    nullable: c_short,

    pub fn init(allocator: std.mem.Allocator) !ColDescription {
        const name_buf = try allocator.alloc(u8, name_buf_len);
        return .{
            .allocator = allocator,
            .name_buf = name_buf,
            .name_buf_len = name_buf_len,
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

pub const SQLDataType = enum(c_short) {
    // https://learn.microsoft.com/en-us/sql/relational-databases/native-client-odbc-date-time/data-type-support-for-odbc-date-and-time-improvements?view=sql-server-ver15
    // SQL Server types
    SS_TIMESTAMPOFFSET = msodbc.SQL_SS_TIMESTAMPOFFSET,
    SS_TIME2 = msodbc.SQL_SS_TIME2,
    SS_TABLE = msodbc.SQL_SS_TABLE,
    SS_XML = msodbc.SQL_SS_XML,
    SS_UDT = msodbc.SQL_SS_UDT,
    SS_VARIANT = msodbc.SQL_SS_VARIANT,

    GUID = c.SQL_GUID,
    WLONGVARCHAR = c.SQL_WLONGVARCHAR,
    WVARCHAR = c.SQL_WVARCHAR,
    WCHAR = c.SQL_WCHAR,
    BIT = c.SQL_BIT,
    TINYINT = c.SQL_TINYINT,
    BIGINT = c.SQL_BIGINT,
    LONGVARBINARY = c.SQL_LONGVARBINARY,
    VARBINARY = c.SQL_VARBINARY,
    BINARY = c.SQL_BINARY,
    LONGVARCHAR = c.SQL_LONGVARCHAR,
    UNKNOWN_TYPE = c.SQL_UNKNOWN_TYPE,
    CHAR = c.SQL_CHAR,
    DECIMAL = c.SQL_DECIMAL,
    NUMERIC = c.SQL_NUMERIC,
    SMALLINT = c.SQL_SMALLINT,
    INTEGER = c.SQL_INTEGER,
    REAL = c.SQL_REAL,
    FLOAT = c.SQL_FLOAT,
    DOUBLE = c.SQL_DOUBLE,
    DATETIME = c.SQL_DATETIME, // verbose type
    INTERVAL = c.SQL_INTERVAL, // verbose type
    VARCHAR = c.SQL_VARCHAR,

    // https://learn.microsoft.com/en-us/sql/odbc/reference/appendixes/data-type-identifiers-and-descriptors?view=sql-server-ver16
    // Concise types
    TYPE_DATE = c.SQL_TYPE_DATE,
    TYPE_TIME = c.SQL_TYPE_TIME,
    TYPE_TIMESTAMP = c.SQL_TYPE_TIMESTAMP,
    INTERVAL_MONTH = c.SQL_INTERVAL_MONTH,
    INTERVAL_YEAR = c.SQL_INTERVAL_YEAR,
    INTERVAL_YEAR_TO_MONTH = c.SQL_INTERVAL_YEAR_TO_MONTH,
    INTERVAL_DAY = c.SQL_INTERVAL_DAY,
    INTERVAL_HOUR = c.SQL_INTERVAL_HOUR,
    INTERVAL_MINUTE = c.SQL_INTERVAL_MINUTE,
    INTERVAL_SECOND = c.SQL_INTERVAL_SECOND,
    INTERVAL_DAY_TO_HOUR = c.SQL_INTERVAL_DAY_TO_HOUR,
    INTERVAL_DAY_TO_MINUTE = c.SQL_INTERVAL_DAY_TO_MINUTE,
    INTERVAL_DAY_TO_SECOND = c.SQL_INTERVAL_DAY_TO_SECOND,
    INTERVAL_HOUR_TO_MINUTE = c.SQL_INTERVAL_HOUR_TO_MINUTE,
    INTERVAL_HOUR_TO_SECOND = c.SQL_INTERVAL_HOUR_TO_SECOND,
    INTERVAL_MINUTE_TO_SECOND = c.SQL_INTERVAL_MINUTE_TO_SECOND,
};

pub const CDataType = enum(c_short) {
    CHAR = c.SQL_C_CHAR,
    LONG = c.SQL_C_LONG,
    SHORT = c.SQL_C_SHORT,
    FLOAT = c.SQL_C_FLOAT,
    DOUBLE = c.SQL_C_DOUBLE,
    NUMERIC = c.SQL_C_NUMERIC,
    DEFAULT = c.SQL_C_DEFAULT,
    DATE = c.SQL_C_DATE,
    TIME = c.SQL_C_TIME,
    TIMESTAMP = c.SQL_C_TIMESTAMP,
    TYPE_DATE = c.SQL_C_TYPE_DATE,
    TYPE_TIME = c.SQL_C_TYPE_TIME,
    TYPE_TIMESTAMP = c.SQL_C_TYPE_TIMESTAMP,
    INTERVAL_YEAR = c.SQL_C_INTERVAL_YEAR,
    INTERVAL_MONTH = c.SQL_C_INTERVAL_MONTH,
    INTERVAL_DAY = c.SQL_C_INTERVAL_DAY,
    INTERVAL_HOUR = c.SQL_C_INTERVAL_HOUR,
    INTERVAL_MINUTE = c.SQL_C_INTERVAL_MINUTE,
    INTERVAL_SECOND = c.SQL_C_INTERVAL_SECOND,
    INTERVAL_YEAR_TO_MONTH = c.SQL_C_INTERVAL_YEAR_TO_MONTH,
    INTERVAL_DAY_TO_HOUR = c.SQL_C_INTERVAL_DAY_TO_HOUR,
    INTERVAL_DAY_TO_MINUTE = c.SQL_C_INTERVAL_DAY_TO_MINUTE,
    INTERVAL_DAY_TO_SECOND = c.SQL_C_INTERVAL_DAY_TO_SECOND,
    INTERVAL_HOUR_TO_MINUTE = c.SQL_C_INTERVAL_HOUR_TO_MINUTE,
    INTERVAL_HOUR_TO_SECOND = c.SQL_C_INTERVAL_HOUR_TO_SECOND,
    INTERVAL_MINUTE_TO_SECOND = c.SQL_C_INTERVAL_MINUTE_TO_SECOND,
    BINARY = c.SQL_C_BINARY,
    BIT = c.SQL_C_BIT,
    SBIGINT = c.SQL_C_SBIGINT,
    UBIGINT = c.SQL_C_UBIGINT,
    TINYINT = c.SQL_C_TINYINT,
    SLONG = c.SQL_C_SLONG,
    SSHORT = c.SQL_C_SSHORT,
    STINYINT = c.SQL_C_STINYINT,
    ULONG = c.SQL_C_ULONG,
    USHORT = c.SQL_C_USHORT,
    UTINYINT = c.SQL_C_UTINYINT,
    // BOOKMARK = c.SQL_C_BOOKMARK,
    GUID = c.SQL_C_GUID,
    // VARBOOKMARK = c.SQL_C_VARBOOKMARK,
    WCHAR = c.SQL_C_WCHAR,
    // TCHAR = c.SQL_C_TCHAR,

    pub fn fromSQL(data_type: c_short) CDataType {
        const sql_data_type: SQLDataType = @enumFromInt(data_type);
        return switch (sql_data_type) {
            // .SMALLINT => CDataType.SHORT,
            // .INTEGER => CDataType.LONG,
            // .CHAR => CDataType.CHAR,
            // .VARCHAR => CDataType.CHAR,
            else => CDataType.DEFAULT,
        };
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
