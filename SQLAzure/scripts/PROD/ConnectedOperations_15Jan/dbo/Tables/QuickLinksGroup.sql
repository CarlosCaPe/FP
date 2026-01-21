CREATE TABLE [dbo].[QuickLinksGroup] (
    [Id] varchar(8) NOT NULL,
    [Title] varchar(128) NOT NULL,
    [DisplayOrder] int NOT NULL,
    [CreatedBy] char(10) NOT NULL,
    [UtcCreatedDate] datetime NOT NULL,
    [ModifiedBy] char(10) NOT NULL,
    [UtcModifiedDate] datetime NOT NULL
);