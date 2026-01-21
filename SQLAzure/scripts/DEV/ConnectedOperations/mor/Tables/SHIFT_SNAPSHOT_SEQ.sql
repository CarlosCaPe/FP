CREATE TABLE [mor].[SHIFT_SNAPSHOT_SEQ] (
    [shiftflag] varchar(4) NOT NULL,
    [siteflag] varchar(3) NOT NULL,
    [shiftid] decimal(19,0) NULL,
    [shiftseq] int NULL,
    [runningtotal] decimal(38,0) NULL,
    [UTC_CREATED_DATE] datetime NULL
);