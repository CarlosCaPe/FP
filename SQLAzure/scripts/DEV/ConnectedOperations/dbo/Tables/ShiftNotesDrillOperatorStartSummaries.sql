CREATE TABLE [dbo].[ShiftNotesDrillOperatorStartSummaries] (
    [SiteCode] char(3) NOT NULL,
    [ShiftDate] datetime NOT NULL,
    [Shift] varchar(16) NOT NULL,
    [Drill] varchar(8) NOT NULL,
    [TimeFirstDrilled] datetime NOT NULL,
    [HolesDrilled] int NOT NULL,
    [ShiftNotes] varchar NOT NULL,
    [CreatedBy] char(10) NOT NULL,
    [UtcCreatedDate] datetime NOT NULL,
    [ModifiedBy] char(10) NOT NULL,
    [UtcModifiedDate] datetime NOT NULL
);