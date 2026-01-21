CREATE TABLE [dbo].[FR_BLAST_SLOPE] (
    [ORIG_SRC_ID] bigint NULL,
    [BLAST_SLOPE_ID] bigint NULL,
    [BLAST_DESIGN_ID] bigint NULL,
    [RELIABILITY] bigint NULL,
    [BFAMIN] bigint NULL,
    [BFADESIGN] bigint NULL,
    [BFAACTUAL] bigint NULL,
    [CBWMIN] bigint NULL,
    [CBWDESIGN] bigint NULL,
    [CBWACTUAL] bigint NULL,
    [MODIFIEDONUTC] datetime NULL,
    [MODIFIEDBY] varchar(50) NULL,
    [NOTAVAILABLE] bit NULL,
    [DW_LOGICAL_DELETE_FLAG] varchar(1) NULL,
    [DW_MODIFY_TS] datetimeoffset NULL,
    [DW_LOAD_TS] datetimeoffset NULL
);