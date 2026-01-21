CREATE TABLE [dbo].[zzz_FLS_Lookups] (
    [TableType] char(4) NOT NULL,
    [TableCode] varchar(8) NOT NULL,
    [TableExtension] varchar(64) NOT NULL,
    [Value] varchar NOT NULL,
    [Description] varchar NOT NULL,
    [CreatedBy] char(10) NOT NULL,
    [UtcCreatedDate] datetime NOT NULL,
    [LastModifiedBy] char(10) NOT NULL,
    [UtcLastModifiedDate] datetime NOT NULL
);