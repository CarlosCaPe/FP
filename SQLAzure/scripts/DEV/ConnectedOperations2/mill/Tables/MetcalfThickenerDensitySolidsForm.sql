CREATE TABLE [mill].[MetcalfThickenerDensitySolidsForm] (
    [TransactionId] int NOT NULL,
    [SiteCode] varchar(3) NOT NULL,
    [TransactionDate] datetime NOT NULL,
    [ShiftId] varchar(3) NOT NULL,
    [RawData] varchar NOT NULL,
    [DensitySolids] varchar NOT NULL,
    [InspectionComment] varchar NOT NULL,
    [CreatedBy] char(10) NOT NULL,
    [UtcCreatedDate] datetime NOT NULL,
    [ModifiedBy] char(10) NOT NULL,
    [UtcModifiedDate] datetime NOT NULL
);