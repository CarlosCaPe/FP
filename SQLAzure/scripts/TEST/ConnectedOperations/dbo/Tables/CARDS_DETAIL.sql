CREATE TABLE [dbo].[CARDS_DETAIL] (
    [Id] int NOT NULL,
    [CardId] int NOT NULL,
    [SiteCode] char(3) NOT NULL,
    [SourceDataLocation] nvarchar(512) NOT NULL,
    [QueryName] nvarchar(512) NOT NULL,
    [Notes] nvarchar NOT NULL,
    [CreatedBy] char(10) NOT NULL,
    [UtcCreatedDate] datetime NOT NULL,
    [ModifiedBy] char(10) NOT NULL,
    [UtcModifiedDate] datetime NOT NULL
);