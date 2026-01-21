CREATE TABLE [dbo].[QuickLinks] (
    [Id] varchar(8) NOT NULL,
    [SiteCode] varchar(3) NOT NULL,
    [ProcessId] varchar(3) NOT NULL,
    [SubProcessId] varchar(3) NOT NULL,
    [Title] varchar(128) NOT NULL,
    [Url] varchar NOT NULL,
    [DisplayOrder] int NOT NULL,
    [CreatedBy] char(10) NOT NULL,
    [UtcCreatedDate] datetime NOT NULL,
    [ModifiedBy] char(10) NOT NULL,
    [UtcModifiedDate] datetime NOT NULL,
    [QuickLinksGroupId] varchar(8) NOT NULL DEFAULT ('INSPFORM')
);