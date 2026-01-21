CREATE TABLE [mill].[KpisRange] (
    [KpiRangeId] int NOT NULL,
    [KpiId] varchar(8) NOT NULL,
    [MinValue] decimal(18,2) NOT NULL,
    [MaxValue] decimal(18,2) NOT NULL,
    [IsTarget] bit NOT NULL,
    [CreatedBy] char(10) NOT NULL,
    [UtcCreatedDate] datetime NOT NULL,
    [ModifiedBy] char(10) NOT NULL,
    [UtcModifiedDate] datetime NOT NULL
);