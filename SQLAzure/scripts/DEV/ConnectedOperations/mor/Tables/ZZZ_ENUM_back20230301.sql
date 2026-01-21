CREATE TABLE [mor].[ZZZ_ENUM_back20230301] (
    [Id] decimal(19,0) NOT NULL,
    [EnumTypeId] decimal(19,0) NOT NULL,
    [Idx] int NULL,
    [Description] varchar(64) NULL,
    [Abbreviation] varchar(32) NULL,
    [Flags] int NOT NULL,
    [UTC_CREATED_DATE] datetime NOT NULL,
    [UTC_LOGICAL_DELETED_DATE] datetime NULL
);