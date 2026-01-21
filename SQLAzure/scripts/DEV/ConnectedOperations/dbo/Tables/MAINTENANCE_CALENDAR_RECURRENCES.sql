CREATE TABLE [dbo].[MAINTENANCE_CALENDAR_RECURRENCES] (
    [Id] int NOT NULL,
    [EventId] int NOT NULL,
    [EventTitle] varchar(512) NOT NULL,
    [EventTypeCode] varchar(8) NOT NULL,
    [EquipmentTypeCode] varchar(8) NOT NULL,
    [EquipmentName] varchar(512) NOT NULL,
    [Description] varchar NOT NULL,
    [StartDateTime] datetime NOT NULL,
    [EndDateTime] datetime NOT NULL,
    [CreatedBy] char(10) NOT NULL,
    [UtcCreatedDate] datetime NOT NULL,
    [LastModifiedBy] char(10) NOT NULL,
    [UtcModifiedDate] datetime NOT NULL
);