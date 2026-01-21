CREATE TABLE [dbo].[QuickLinksName] (
    [Id] varchar(8) NOT NULL,
    [LanguageCode] char(2) NOT NULL,
    [Title] varchar(128) NOT NULL,
    [CreatedBy] char(10) NOT NULL,
    [UtcCreatedDate] datetime NOT NULL,
    [ModifiedBy] char(10) NOT NULL,
    [UtcModifiedDate] datetime NOT NULL
);