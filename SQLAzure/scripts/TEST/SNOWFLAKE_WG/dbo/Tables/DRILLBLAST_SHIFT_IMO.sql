CREATE TABLE [dbo].[DRILLBLAST_SHIFT_IMO] (
    [ORIG_SRC_ID] int NULL,
    [SITE_CODE] varchar(5) NOT NULL,
    [SHIFT_ID] varchar(500) NOT NULL,
    [SHIFT_DATE] varchar(50) NULL,
    [SHIFT_NAME] varchar(255) NULL,
    [SHIFT_DATE_NAME] varchar(255) NULL,
    [ATTRIBUTED_CREW_ID] bigint NULL,
    [CREW_NAME] varchar(255) NULL,
    [SHIFT_NO] int NULL,
    [SHIFT_START_TS_UTC] varchar(50) NULL,
    [SHIFT_END_TS_UTC] varchar(50) NULL,
    [SHIFT_START_TS_LOCAL] varchar(50) NULL,
    [SHIFT_END_TS_LOCAL] varchar(50) NULL,
    [SYSTEM_VERSION] varchar(50) NULL,
    [DW_LOAD_TS] varchar(50) NULL,
    [DW_MODIFY_TS] varchar(50) NULL
);