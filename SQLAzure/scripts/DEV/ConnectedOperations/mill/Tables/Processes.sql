CREATE TABLE [mill].[Processes] (
    [ProcessId] varchar(3) NOT NULL,
    [ProcessName] varchar(50) NOT NULL,
    [DisplayOrder] tinyint NOT NULL,
    [CreatedBy] varchar(10) NOT NULL,
    [UtcCreatedDate] datetime NOT NULL,
    [ModifiedBy] varchar(10) NOT NULL,
    [UtcModifiedDate] datetime NOT NULL
);