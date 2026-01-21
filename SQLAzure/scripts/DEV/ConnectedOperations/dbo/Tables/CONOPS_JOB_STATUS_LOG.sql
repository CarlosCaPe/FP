CREATE TABLE [dbo].[CONOPS_JOB_STATUS_LOG] (
    [ID] int NOT NULL,
    [SITE_CODE] varchar(10) NULL,
    [JOB_NAME] varchar(100) NULL,
    [TABLE_NAME] varchar(100) NULL,
    [JOB_TYPE] varchar(50) NULL,
    [MAX_DATA_LOCAL_TS] datetime NULL,
    [MAX_DATA_LOAD_LOCAL_TS] datetime NULL,
    [MAX_DATA_LOAD_UTC] datetime NULL,
    [LATE_MINS] int NULL,
    [JOB_SCHEDULE_MINS] int NULL,
    [JOB_ALERT_MINS] int NULL,
    [EXECUTED_BY] varchar(100) NULL,
    [UTC_CREATED_DATE] datetime NULL,
    [SERVER_CREATED_DATE] datetime NULL
);