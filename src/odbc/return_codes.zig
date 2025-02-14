pub const c = @cImport({
    @cInclude("sql.h");
    @cInclude("sqltypes.h");
    @cInclude("sqlext.h");
});

pub const sqlret = struct {
    pub const success = c.SQL_SUCCESS;
    pub const success_with_info = c.SQL_SUCCESS_WITH_INFO;
    pub const err = c.SQL_ERROR;
    pub const invalid_handle = c.SQL_INVALID_HANDLE;
    pub const still_executing = c.SQL_STILL_EXECUTING;
    pub const need_data = c.SQL_NEED_DATA;
    pub const no_data_found = c.SQL_NO_DATA_FOUND;
};

pub fn retconv1(rc: i32) !void {
    return switch (rc) {
        sqlret.success => {},
        sqlret.success_with_info => error.Info,
        sqlret.err => error.Error,
        sqlret.invalid_handle => error.InvalidHandle,
        else => unreachable,
    };
}

pub const AllocHandleRC = enum(c_short) {
    SUCCESS = c.SQL_SUCCESS,
    SUCCESS_WITH_INFO = c.SQL_SUCCESS_WITH_INFO,
    ERR = c.SQL_ERROR,
    INVALID_HANDLE = c.SQL_INVALID_HANDLE,
};

pub const FreeHandleRC = enum(c_short) {
    SUCCESS = c.SQL_SUCCESS,
    SUCCESS_WITH_INFO = c.SQL_SUCCESS_WITH_INFO,
    ERR = c.SQL_ERROR,
    INVALID_HANDLE = c.SQL_INVALID_HANDLE,
};

pub const GetEnvAttrRC = enum(c_short) {
    SUCCESS = c.SQL_SUCCESS,
    ERR = c.SQL_ERROR,
    INVALID_HANDLE = c.SQL_INVALID_HANDLE,
};

pub const SetEnvAttrRC = enum(c_short) {
    SUCCESS = c.SQL_SUCCESS,
    ERR = c.SQL_ERROR,
    INVALID_HANDLE = c.SQL_INVALID_HANDLE,
};

pub const GetInfoRC = enum(c_short) {
    SUCCESS = c.SQL_SUCCESS,
    SUCCESS_WITH_INFO = c.SQL_SUCCESS_WITH_INFO,
    ERR = c.SQL_ERROR,
    INVALID_HANDLE = c.SQL_INVALID_HANDLE,
};

pub const GetConnectAttrRC = enum(c_short) {
    SUCCESS = c.SQL_SUCCESS,
    SUCCESS_WITH_INFO = c.SQL_SUCCESS_WITH_INFO,
    ERR = c.SQL_ERROR,
    INVALID_HANDLE = c.SQL_INVALID_HANDLE,
    NO_DATA = c.SQL_NO_DATA,
};

pub const SetConnectAttrRC = enum(c_short) {
    SUCCESS = c.SQL_SUCCESS,
    ERR = c.SQL_ERROR,
    INVALID_HANDLE = c.SQL_INVALID_HANDLE,
};

pub const DriverConnectRC = enum(c_short) {
    SUCCESS = c.SQL_SUCCESS,
    SUCCESS_WITH_INFO = c.SQL_SUCCESS_WITH_INFO,
    ERR = c.SQL_ERROR,
    INVALID_HANDLE = c.SQL_INVALID_HANDLE,
    NO_DATA_FOUND = c.SQL_NO_DATA_FOUND,
};

pub const SetStatementAttrRC = enum(c.SQLRETURN) {
    SUCCESS = c.SQL_SUCCESS,
    SUCCESS_WITH_INFO = c.SQL_SUCCESS_WITH_INFO,
    ERR = c.SQL_ERROR,
};

pub const ColumnsRC = enum(c_short) {
    SUCCESS = c.SQL_SUCCESS,
    SUCCESS_WITH_INFO = c.SQL_SUCCESS_WITH_INFO,
    ERR = c.SQL_ERROR,
    INVALID_HANDLE = c.SQL_INVALID_HANDLE,
};

pub const PrepareRC = enum(c_short) {
    SUCCESS = c.SQL_SUCCESS,
    SUCCESS_WITH_INFO = c.SQL_SUCCESS_WITH_INFO,
    ERR = c.SQL_ERROR,
    INVALID_HANDLE = c.SQL_INVALID_HANDLE,
};

pub const NumResultColsRC = enum(c_short) {
    SUCCESS = c.SQL_SUCCESS,
    ERR = c.SQL_ERROR,
    INVALID_HANDLE = c.SQL_INVALID_HANDLE,
    STILL_EXECUTING = c.SQL_STILL_EXECUTING,
};

pub const DescribeColRC = enum(c_short) {
    SUCCESS = c.SQL_SUCCESS,
    ERR = c.SQL_ERROR,
    INVALID_HANDLE = c.SQL_INVALID_HANDLE,
    // TODO:
    // - can this be an error state???
    // STILL_EXECUTING = c.SQL_STILL_EXECUTING,
};

pub const BindColRC = enum(c_short) {
    SUCCESS = c.SQL_SUCCESS,
    ERR = c.SQL_ERROR,
    INVALID_HANDLE = c.SQL_INVALID_HANDLE,
};

pub const ExecuteRC = enum(c_short) {
    SUCCESS = c.SQL_SUCCESS,
    SUCCESS_WITH_INFO = c.SQL_SUCCESS_WITH_INFO,
    ERR = c.SQL_ERROR,
    INVALID_HANDLE = c.SQL_INVALID_HANDLE,
    NEED_DATA = c.SQL_NEED_DATA,
    NO_DATA_FOUND = c.SQL_NO_DATA_FOUND,
};

pub const ExecDirectRC = enum(c_short) {
    SUCCESS = c.SQL_SUCCESS,
    SUCCESS_WITH_INFO = c.SQL_SUCCESS_WITH_INFO,
    ERR = c.SQL_ERROR,
    INVALID_HANDLE = c.SQL_INVALID_HANDLE,
    NEED_DATA = c.SQL_NEED_DATA,
    NO_DATA_FOUND = c.SQL_NO_DATA_FOUND,
};

pub const FetchRC = enum(c_short) {
    SUCCESS = c.SQL_SUCCESS,
    SUCCESS_WITH_INFO = c.SQL_SUCCESS_WITH_INFO,
    ERR = c.SQL_ERROR,
    INVALID_HANDLE = c.SQL_INVALID_HANDLE,
    NO_DATA_FOUND = c.SQL_NO_DATA_FOUND,
};

pub const FetchScrollRC = enum(c_short) {
    SUCCESS = c.SQL_SUCCESS,
    SUCCESS_WITH_INFO = c.SQL_SUCCESS_WITH_INFO,
    ERR = c.SQL_ERROR,
    INVALID_HANDLE = c.SQL_INVALID_HANDLE,
    // NEED_DATA = c.SQL_NEED_DATA,
    // NO_DATA_FOUND = c.SQL_NO_DATA_FOUND,
};
