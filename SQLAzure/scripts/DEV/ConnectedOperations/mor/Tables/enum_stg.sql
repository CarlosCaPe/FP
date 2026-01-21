CREATE TABLE [mor].[enum_stg] (
    [Id] decimal(19,0) NOT NULL,
    [EnumTypeId] decimal(19,0) NOT NULL,
    [Idx] int NULL,
    [Description] varchar(64) NULL,
    [Abbreviation] varchar(32) NULL,
    [Flags] int NOT NULL,
    [change_type] varchar(1) NOT NULL,
    [change_id] decimal(19,0) NOT NULL,
    [UTC_CREATED_DATE] datetime NOT NULL,
    [UTC_LOGICAL_DELETED_DATE] datetime NULL
);