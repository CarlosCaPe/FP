CREATE TABLE [dbo].[FR_BLAST_DESIGN] (
    [ORIG_SRC_ID] bigint NULL,
    [BLAST_DESIGN_ID] bigint NULL,
    [SITE_CODE] varchar(4) NULL,
    [SCHEDULEDDATE] datetime NULL,
    [MODIFIEDONUTC] datetime NULL,
    [MODIFIEDBY] varchar(50) NULL,
    [OBJECTIVE] varchar(20) NULL,
    [PRIMARYROCKTYPE] varchar(100) NULL,
    [SECONDARYROCKTYPE] varchar(100) NULL,
    [BLAST_SECTOR] bigint NULL,
    [DW_LOGICAL_DELETE_FLAG] varchar(1) NULL,
    [DW_MODIFY_TS] datetimeoffset NULL,
    [DW_LOAD_TS] datetimeoffset NULL
);