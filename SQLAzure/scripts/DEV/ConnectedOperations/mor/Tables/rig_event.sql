CREATE TABLE [mor].[rig_event] (
    [Id] varchar(36) NOT NULL,
    [RigId] varchar(36) NULL,
    [Time] datetime NOT NULL,
    [Data] varchar(64) NULL,
    [TypeOfEventId] int NOT NULL,
    [EndTime] datetime NULL,
    [IsEdited] bit NOT NULL,
    [Comment] varchar(512) NULL,
    [TumCodeId] int NULL,
    [IsTumCode] bit NULL,
    [UTC_CREATED_DATE] datetime NOT NULL,
    [UTC_LOGICAL_DELETED_DATE] datetime NULL
);