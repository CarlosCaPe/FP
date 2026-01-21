CREATE TABLE [dbo].[MAINTENANCE_CALENDAR_RECURRENCES_B20240522] (
    [Id] int NOT NULL,
    [EventId] int NOT NULL,
    [StartDateTime] datetime NOT NULL,
    [EndDateTime] datetime NOT NULL,
    [CreatedBy] char(10) NOT NULL,
    [UtcCreatedDate] datetime NOT NULL,
    [LastModifiedBy] char(10) NOT NULL,
    [UtcModifiedDate] datetime NOT NULL
);