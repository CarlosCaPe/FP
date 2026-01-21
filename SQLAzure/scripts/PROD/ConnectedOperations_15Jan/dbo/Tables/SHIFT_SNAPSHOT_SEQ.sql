CREATE TABLE [dbo].[SHIFT_SNAPSHOT_SEQ] (
    [SITEFLAG] varchar(3) NOT NULL,
    [SHIFTID] decimal(19,0) NULL,
    [SHIFTSEQ] int NULL,
    [RUNNINGTOTAL] decimal(38,0) NULL,
    [UTC_CREATED_DATE] datetime NULL
);