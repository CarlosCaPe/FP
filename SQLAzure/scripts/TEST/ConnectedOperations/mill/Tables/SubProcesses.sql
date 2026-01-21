CREATE TABLE [mill].[SubProcesses] (
    [ProcessId] varchar(3) NOT NULL,
    [SubProcessId] varchar(3) NOT NULL,
    [SubProcessName] varchar(50) NOT NULL,
    [DisplayOrder] tinyint NOT NULL,
    [CreatedBy] varchar(10) NOT NULL,
    [UtcCreatedDate] datetime NOT NULL,
    [ModifiedBy] varchar(10) NOT NULL,
    [UtcModifiedDate] datetime NOT NULL
);