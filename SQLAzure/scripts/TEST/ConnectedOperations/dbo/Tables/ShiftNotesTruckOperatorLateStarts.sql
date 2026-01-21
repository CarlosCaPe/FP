CREATE TABLE [dbo].[ShiftNotesTruckOperatorLateStarts] (
    [SiteCode] char(3) NOT NULL,
    [ShiftDate] datetime NOT NULL,
    [Shift] varchar(16) NOT NULL,
    [Region] varchar(64) NOT NULL,
    [NumberOfLate] int NOT NULL,
    [ShiftNotes] varchar NOT NULL,
    [CreatedBy] char(10) NOT NULL,
    [UtcCreatedDate] datetime NOT NULL,
    [ModifiedBy] char(10) NOT NULL,
    [UtcModifiedDate] datetime NOT NULL
);