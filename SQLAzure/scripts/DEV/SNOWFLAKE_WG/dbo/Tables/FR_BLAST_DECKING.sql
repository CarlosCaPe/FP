CREATE TABLE [dbo].[FR_BLAST_DECKING] (
    [ORIG_SRC_ID] bigint NULL,
    [BLAST_DECKING_ID] bigint NULL,
    [BLAST_PATTERN_ID] bigint NULL,
    [FIRSTSTEM] decimal(5,2) NULL,
    [SECONDSTEM] decimal(5,2) NULL,
    [STEMTOCOLLAR] decimal(5,2) NULL,
    [EXPLOSIVETYPE] varchar(20) NULL,
    [EXPLOSIVEAMOUNT] decimal(6,2) NULL,
    [MODIFIEDONUTC] datetime NULL,
    [MODIFIEDBY] varchar(50) NULL,
    [ISDELETED] bigint NULL,
    [DW_LOGICAL_DELETE_FLAG] varchar(1) NULL,
    [DW_MODIFY_TS] datetimeoffset NULL,
    [DW_LOAD_TS] datetimeoffset NULL
);