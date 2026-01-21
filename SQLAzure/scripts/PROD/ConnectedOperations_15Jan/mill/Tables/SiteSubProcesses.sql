CREATE TABLE [mill].[SiteSubProcesses] (
    [SiteCode] varchar(3) NOT NULL,
    [ProcessId] varchar(3) NOT NULL,
    [SubProcessId] varchar(3) NOT NULL,
    [IsEnabled] bit NOT NULL,
    [CreatedBy] varchar(10) NOT NULL,
    [UtcCreatedDate] datetime NOT NULL,
    [ModifiedBy] varchar(10) NOT NULL,
    [UtcModifiedDate] datetime NOT NULL
);