CREATE TABLE [dbo].[CARDS_HEADER] (
    [Id] int NOT NULL,
    [CardId] int NOT NULL,
    [LanguageCode] char(2) NOT NULL,
    [CardTitle] varchar(128) NOT NULL,
    [CardDescription] nvarchar NOT NULL,
    [Notes] nvarchar NOT NULL,
    [CreatedBy] char(10) NOT NULL,
    [UtcCreatedDate] datetime NOT NULL,
    [ModifiedBy] char(10) NOT NULL,
    [UtcModifiedDate] datetime NOT NULL
);