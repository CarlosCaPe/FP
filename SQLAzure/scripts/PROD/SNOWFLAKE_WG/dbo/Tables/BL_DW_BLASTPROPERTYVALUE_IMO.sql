CREATE TABLE [dbo].[BL_DW_BLASTPROPERTYVALUE_IMO] (
    [ORIG_SRC_ID] bigint NOT NULL,
    [SITE_CODE] varchar(50) NOT NULL,
    [BLASTID] int NOT NULL,
    [REFRESHEDTIME] varchar(50) NULL,
    [DELETED] bit NULL,
    [PARAMETER] varchar(400) NULL,
    [PLANNEDDATE] varchar(400) NULL,
    [SHOTTYPE] varchar(400) NULL,
    [SHOTGOAL] varchar(400) NULL,
    [DW_MODIFY_TS] varchar(50) NULL,
    [DW_LOAD_TS] varchar(50) NULL,
    [DW_FILE_TS_UTC] varchar(50) NULL
);