CREATE TABLE [mill].[KpisGroup] (
    [SiteCode] varchar(3) NOT NULL,
    [ProcessId] varchar(3) NOT NULL,
    [SubProcessId] varchar(3) NOT NULL,
    [KpiGroupId] varchar(8) NOT NULL,
    [KpiGroupName] varchar(50) NOT NULL,
    [CreatedBy] char(10) NOT NULL,
    [UtcCreatedDate] datetime NOT NULL,
    [ModifiedBy] char(10) NOT NULL,
    [UtcModifiedDate] datetime NOT NULL
);