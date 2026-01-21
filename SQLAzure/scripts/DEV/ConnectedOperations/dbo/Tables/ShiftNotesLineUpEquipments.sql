CREATE TABLE [dbo].[ShiftNotesLineUpEquipments] (
    [SiteCode] char(3) NOT NULL,
    [ShiftDate] datetime NOT NULL,
    [Shift] varchar(16) NOT NULL,
    [Equipment] varchar(64) NOT NULL,
    [EquipmentAvailableShiftStart] int NOT NULL,
    [ShiftNotes] varchar NULL,
    [CreatedBy] char(10) NOT NULL,
    [UtcCreatedDate] datetime NOT NULL,
    [ModifiedBy] char(10) NOT NULL,
    [UtcModifiedDate] datetime NOT NULL
);