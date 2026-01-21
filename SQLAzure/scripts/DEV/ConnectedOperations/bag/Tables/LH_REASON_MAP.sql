CREATE TABLE [bag].[LH_REASON_MAP] (
    [SITE_CODE] varchar(5) NULL,
    [REASON_CODE] int NULL,
    [REASON] varchar(512) NULL,
    [TIME_CATEGORY_CODE] int NULL,
    [TIME_CATEGORY] varchar(512) NULL,
    [TIME_CATEGORY_1] varchar(512) NULL,
    [TIME_CATEGORY_2] varchar(512) NULL,
    [MAINT_EVENT] int NULL,
    [UNPLANNED_MAINT] int NULL,
    [PLANNED_MAINT] int NULL,
    [OPER_EVENT] int NULL,
    [CREATED_BY] varchar(512) NULL,
    [CREATED_TS] datetime NULL,
    [LAST_UPDATED_BY] varchar(512) NULL,
    [LAST_UPDATED_TS] datetime NULL
);