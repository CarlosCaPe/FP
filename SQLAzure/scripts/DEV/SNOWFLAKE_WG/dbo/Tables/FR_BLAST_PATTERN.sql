CREATE TABLE [dbo].[FR_BLAST_PATTERN] (
    [ORIG_SRC_ID] bigint NULL,
    [BLAST_PATTERN_ID] bigint NULL,
    [SITE_CODE] varchar(5) NULL,
    [PATTERNDECIMAL] varchar(50) NULL,
    [HOLEDECIMAL] varchar(50) NULL,
    [BENCH] decimal(10,3) NULL,
    [XPOS] decimal(20,10) NULL,
    [YPOS] decimal(20,10) NULL,
    [ZPOS] decimal(20,10) NULL,
    [BLAST_DESIGN_ID] bigint NULL,
    [CREATEDONUTC] datetime NULL,
    [MODIFIEDONUTC] datetime NULL,
    [DW_LOGICAL_DELETE_FLAG] varchar(1) NULL,
    [DW_MODIFY_TS] datetimeoffset NULL,
    [DW_LOAD_TS] datetimeoffset NULL
);