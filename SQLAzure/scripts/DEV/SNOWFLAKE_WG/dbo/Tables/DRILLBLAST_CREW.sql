CREATE TABLE [dbo].[DRILLBLAST_CREW] (
    [ORIG_SRC_ID] decimal(4,0) NULL,
    [SITE_CODE] varchar(4) NOT NULL,
    [CREW_ID] bigint NOT NULL,
    [CREW_NAME] varchar(1016) NULL,
    [CREW_SUPERVISOR] varchar(14) NULL,
    [SYSTEM_VERSION] varchar(50) NULL,
    [DW_LOAD_TS] datetime2 NULL,
    [DW_MODIFY_TS] datetime2 NULL
);