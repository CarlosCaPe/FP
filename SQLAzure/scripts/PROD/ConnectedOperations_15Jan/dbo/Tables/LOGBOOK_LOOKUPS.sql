CREATE TABLE [dbo].[LOGBOOK_LOOKUPS] (
    [LogbookType] char(2) NOT NULL,
    [SiteCode] varchar(3) NOT NULL DEFAULT (''),
    [ProcessId] varchar(3) NOT NULL DEFAULT (''),
    [SubProcessId] varchar(3) NOT NULL DEFAULT (''),
    [TableType] char(4) NOT NULL,
    [TableCode] varchar(8) NOT NULL,
    [LanguageCode] char(2) NOT NULL,
    [Value] nvarchar NOT NULL,
    [Description] nvarchar NOT NULL,
    [IsActive] bit NOT NULL,
    [CreatedBy] char(10) NOT NULL,
    [UtcCreatedDate] datetime NOT NULL,
    [ModifiedBy] char(10) NOT NULL,
    [UtcModifiedDate] datetime NOT NULL
);