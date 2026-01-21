CREATE TABLE [dbo].[SHIFT_DATE_STG] (
    [SHIFTINDEX] decimal(19,0) NOT NULL,
    [SHIFTDATE] date NOT NULL,
    [SITE_CODE] varchar(4) NOT NULL,
    [CLIID] decimal(19,0) NULL,
    [NAME] varchar(50) NULL,
    [YEARS] float NULL,
    [MONTH_CODE] decimal(19,0) NULL,
    [MONTHS] varchar(5) NULL,
    [DAYS] int NULL,
    [SHIFT_CODE] int NULL,
    [SHIFT] varchar(20) NULL,
    [DATES] float NULL,
    [STARTS] float NULL,
    [LEN] float NULL,
    [DISPTIME] float NULL,
    [UTC_CREATED_DATE] datetime NOT NULL,
    [UTC_LOGICAL_DELETED_DATE] datetime NULL
);