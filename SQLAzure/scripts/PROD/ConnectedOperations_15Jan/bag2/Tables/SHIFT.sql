CREATE TABLE [bag2].[SHIFT] (
    [SITEFLAG] varchar(5) NOT NULL,
    [OID] bigint NOT NULL,
    [VERSION] int NOT NULL,
    [STARTTIME_UTC] datetime2 NOT NULL,
    [ENDTIME_UTC] datetime2 NOT NULL,
    [SHIFTTYPE] smallint NOT NULL,
    [CREW] bigint NULL,
    [NAME] nvarchar(254) NOT NULL,
    [DAY] nvarchar(32) NOT NULL,
    [WEEK] nvarchar(32) NOT NULL,
    [MONTH] nvarchar(32) NOT NULL,
    [QUARTER] nvarchar(32) NOT NULL,
    [HALF] nvarchar(32) NOT NULL,
    [YEAR] nvarchar(32) NOT NULL,
    [REPORTING_DATE] nvarchar(8) NULL,
    [UTC_CREATED_DATE] datetime NOT NULL,
    [UTC_LOGICAL_DELETED_DATE] datetime NULL
);