CREATE TABLE [dbo].[ShiftNotes] (
    [ShiftNotesId] uniqueidentifier NOT NULL,
    [SiteCode] char(3) NOT NULL,
    [Shift] varchar(16) NOT NULL,
    [ShiftDate] datetime NOT NULL,
    [Category] varchar(64) NOT NULL,
    [ShiftNotes] varchar NOT NULL,
    [CreatedBy] char(10) NOT NULL,
    [UtcCreatedDate] datetime NOT NULL,
    [ModifiedBy] char(10) NOT NULL,
    [UtcModifiedDate] datetime NOT NULL
);