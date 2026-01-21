CREATE TYPE [dbo].[LogbookAttachmentList] AS TABLE (
    [Title] varchar(512) NOT NULL,
    [AttachmentUrl] varchar(512) NOT NULL,
    [LogbookId] int NULL
);