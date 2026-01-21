CREATE TABLE [mor].[rig] (
    [Id] varchar(36) NOT NULL,
    [Name] varchar(256) NOT NULL,
    [SerialNumber] varchar(64) NOT NULL,
    [RigInformationDate] datetime NULL,
    [ExportPath] varchar(256) NULL,
    [RRAStatusId] varchar(36) NOT NULL,
    [HasGps] bit NOT NULL,
    [EquipmentType] varchar(256) NULL,
    [IsArchived] bit NOT NULL,
    [UTC_CREATED_DATE] datetime NOT NULL,
    [UTC_LOGICAL_DELETED_DATE] datetime NULL
);