CREATE TABLE [dbo].[TARGET_LOOKUP] (
    [SITEFLAG] varchar(5) NOT NULL,
    [PAGE_TYPE] varchar(20) NULL,
    [DAILY_PLAN] varchar(200) NULL,
    [MONTHLY_PLAN] varchar(200) NULL,
    [UTC_CREATED_DATE] datetime NOT NULL
);