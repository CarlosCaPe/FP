CREATE TABLE [dbo].[LOGBOOK_TEMP202311] (
    [Id] int NOT NULL,
    [SiteCode] char(3) NOT NULL,
    [Title] nvarchar(512) NOT NULL,
    [Description] nvarchar NOT NULL,
    [PhotoUrl] varchar(512) NOT NULL,
    [ImportanceCode] varchar(8) NOT NULL,
    [AreaCode] varchar(8) NOT NULL,
    [ExtendedProperties] nvarchar NULL,
    [IsActive] bit NOT NULL,
    [CreatedBy] char(10) NOT NULL,
    [UtcCreatedDate] datetime NOT NULL,
    [ModifiedBy] char(10) NOT NULL,
    [UtcModifiedDate] datetime NOT NULL
);