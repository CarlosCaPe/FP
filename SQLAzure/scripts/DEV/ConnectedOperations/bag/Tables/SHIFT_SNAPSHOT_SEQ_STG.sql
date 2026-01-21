CREATE TABLE [bag].[SHIFT_SNAPSHOT_SEQ_STG] (
    [SHIFTFLAG] varchar(4) NOT NULL,
    [SITEFLAG] varchar(3) NOT NULL,
    [SHIFTID] decimal(19,0) NULL,
    [SHIFTSEQ] int NULL,
    [RUNNINGTOTAL] decimal(38,0) NULL,
    [UTC_CREATED_DATE] datetime NULL
);