CREATE TABLE [dbo].[LOOKUPS] (
    [TableType] char(4) NOT NULL,
    [TableCode] varchar(8) NOT NULL,
    [LanguageCode] varchar(2) NOT NULL,
    [Value] nvarchar NOT NULL,
    [Description] nvarchar NOT NULL,
    [IsActive] bit NOT NULL,
    [CreatedBy] char(10) NOT NULL,
    [UtcCreatedDate] datetime NOT NULL,
    [ModifiedBy] char(10) NOT NULL,
    [UtcModifiedDate] datetime NOT NULL
);