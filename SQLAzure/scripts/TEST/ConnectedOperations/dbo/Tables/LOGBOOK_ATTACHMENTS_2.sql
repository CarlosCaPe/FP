CREATE TABLE [dbo].[LOGBOOK_ATTACHMENTS_2] (
    [Id] int NOT NULL,
    [LogbookId] int NOT NULL,
    [Title] varchar(512) NOT NULL,
    [AttachmentUrl] varchar(512) NOT NULL,
    [CreatedBy] char(10) NOT NULL,
    [UtcCreatedDate] datetime NOT NULL,
    [ModifiedBy] char(10) NOT NULL,
    [UtcModifiedDate] datetime NOT NULL
);