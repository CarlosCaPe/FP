CREATE TABLE [dbo].[OEE] (
    [SITE_CODE] varchar(4) NOT NULL,
    [SHIFTINDEX] numeric(38,0) NOT NULL,
    [SHIFTDATE] date NULL,
    [SHIFT] varchar(64) NULL,
    [READYTIME] float NULL,
    [TOTALTIME] float NULL,
    [SHOVELLOADCOUNT] numeric(18,0) NULL,
    [LOADERLOADCOUNT] numeric(18,0) NULL,
    [TOTALCYCLETIME] float NULL,
    [DELTAC] float NULL,
    [EQMT] varchar(50) NOT NULL,
    [HOS] numeric(38,0) NOT NULL,
    [CYCLECOUNT] numeric(18,0) NULL,
    [UTC_CREATED_DATE] datetime NULL
);