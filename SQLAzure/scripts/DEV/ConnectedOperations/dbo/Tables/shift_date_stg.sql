CREATE TABLE [dbo].[shift_date_stg] (
    [shiftindex] decimal(19,0) NOT NULL,
    [shiftdate] date NOT NULL,
    [site_code] varchar(4) NOT NULL,
    [cliid] decimal(19,0) NULL,
    [name] varchar(50) NULL,
    [years] float NULL,
    [month_code] decimal(19,0) NULL,
    [months] varchar(5) NULL,
    [days] int NULL,
    [shift_code] int NULL,
    [shift] varchar(20) NULL,
    [dates] float NULL,
    [starts] float NULL,
    [len] float NULL,
    [disptime] float NULL,
    [UTC_CREATED_DATE] datetime NOT NULL,
    [UTC_LOGICAL_DELETED_DATE] datetime NULL
);