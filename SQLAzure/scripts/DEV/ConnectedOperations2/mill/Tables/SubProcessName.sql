CREATE TABLE [mill].[SubProcessName] (
    [SubProcessId] varchar(3) NOT NULL,
    [LanguageCode] varchar(5) NOT NULL,
    [SubProcessName] varchar(50) NOT NULL,
    [CreatedBy] varchar(10) NOT NULL,
    [UtcCreatedDate] datetime NOT NULL,
    [ModifiedBy] varchar(10) NOT NULL,
    [UtcModifiedDate] datetime NOT NULL
);