CREATE TABLE [mor].[rig_stg] (
    [Id] varchar(36) NOT NULL,
    [Name] varchar(256) NOT NULL,
    [SerialNumber] varchar(64) NOT NULL,
    [RigInformationDate] datetime NULL,
    [ExportPath] varchar(256) NULL,
    [RRAStatusId] varchar(36) NOT NULL,
    [HasGps] bit NOT NULL,
    [EquipmentType] varchar(256) NULL,
    [IsArchived] bit NOT NULL,
    [change_type] varchar(1) NOT NULL,
    [change_id] decimal(19,0) NOT NULL,
    [UTC_CREATED_DATE] datetime NOT NULL,
    [UTC_LOGICAL_DELETED_DATE] datetime NULL
);