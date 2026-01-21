CREATE TABLE [dbo].[EFH_SNAPSHOT_SEQ] (
    [siteflag] varchar(3) NOT NULL,
    [shiftid] decimal(19,0) NOT NULL,
    [ShiftStartDateTime] datetime NOT NULL,
    [ShiftEndDateTime] datetime NOT NULL,
    [CurrentTime] datetime NOT NULL,
    [EFH] decimal(38,6) NULL,
    [EFHTarget] decimal(38,6) NULL,
    [EFHSeq] int NOT NULL,
    [UTC_CREATED_DATE] datetime NULL
);