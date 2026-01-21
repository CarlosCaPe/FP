CREATE TYPE [dbo].[LH_REASON_STG_2_IMO] AS TABLE (
    [SHIFTINDEX] numeric(38,0) NOT NULL,
    [SHIFTDATE] date NOT NULL,
    [SITE_CODE] varchar(4) NOT NULL,
    [CLIID] numeric(38,0) NOT NULL,
    [DDBKEY] float NOT NULL,
    [NAME] varchar(30) NULL,
    [REASON] float NOT NULL,
    [STATUS] float NULL,
    [DELAYTIME] float NULL,
    [CATEGORY] float NULL,
    [MAINTTIME] varchar(4) NULL,
    [SYSTEM_VERSION] varchar(50) NULL,
    [UTC_CREATED_DATE] datetime NULL
);