CREATE TABLE [dbo].[CARDS] (
    [Id] int NOT NULL,
    [CardName] varchar(128) NOT NULL,
    [CreatedBy] char(10) NOT NULL,
    [UtcCreatedDate] datetime NOT NULL,
    [ModifiedBy] char(10) NOT NULL,
    [UtcModifiedDate] datetime NOT NULL
);