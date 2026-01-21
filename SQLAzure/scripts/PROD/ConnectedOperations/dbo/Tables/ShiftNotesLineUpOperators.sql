CREATE TABLE [dbo].[ShiftNotesLineUpOperators] (
    [SiteCode] char(3) NOT NULL,
    [ShiftDate] datetime NOT NULL,
    [Shift] varchar(16) NOT NULL,
    [Operator] varchar(16) NOT NULL,
    [Actual] int NOT NULL,
    [Plan] int NOT NULL,
    [ShiftNotes] varchar NOT NULL,
    [CreatedBy] char(10) NOT NULL,
    [UtcCreatedDate] datetime NOT NULL,
    [ModifiedBy] char(10) NOT NULL,
    [UtcModifiedDate] datetime NOT NULL
);