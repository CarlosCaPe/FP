CREATE TABLE [dbo].[DI_JOB_CONTROL_ENTRY_TS_BASE] (
    [job_name] varchar(255) NOT NULL,
    [extract_low_ts] datetime NULL,
    [extract_high_ts] datetime NULL,
    [extract_low_id] int NULL,
    [extract_high_id] int NULL,
    [extract_low_date] smalldatetime NULL,
    [extract_high_date] smalldatetime NULL,
    [extract_low_char] varchar(30) NULL,
    [extract_high_char] varchar(30) NULL,
    [bulk_load_flag] varchar(1) NULL,
    [lookback_days] int NULL,
    [lookback_days_dec] decimal(8,4) NULL,
    [dw_load_ts] datetime NULL,
    [JOB_QUEUE] varchar(50) NULL
);