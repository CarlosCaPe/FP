CREATE TABLE [dbo].[LH_SHIFT] (
    [SHIFT_ID] varchar(255) NOT NULL,
    [ORIG_SRC_ID] numeric(4,0) NULL,
    [SITE_CODE] varchar(4) NULL,
    [SHIFT_DATE] date NULL,
    [SHIFT_NAME] varchar(2033) NULL,
    [SHIFT_DATE_NAME] varchar(255) NULL,
    [ATTRIBUTED_CREW_ID] numeric(38,0) NULL,
    [CREW_NAME] varchar(1016) NULL,
    [SHIFT_NO] numeric(38,0) NULL,
    [SHIFT_START_TS_UTC] datetime NULL,
    [SHIFT_END_TS_UTC] datetime NULL,
    [SHIFT_START_TS_LOCAL] datetime NULL,
    [SHIFT_END_TS_LOCAL] datetime NULL,
    [SYSTEM_VERSION] varchar(50) NULL,
    [DW_LOAD_TS] datetime2 NULL,
    [DW_MODIFY_TS] datetime2 NULL
);