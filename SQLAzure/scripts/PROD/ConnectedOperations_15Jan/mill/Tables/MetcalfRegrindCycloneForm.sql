CREATE TABLE [mill].[MetcalfRegrindCycloneForm] (
    [TransactionId] int NOT NULL,
    [SiteCode] varchar(3) NOT NULL,
    [TransactionDate] datetime NOT NULL,
    [RawData] varchar NOT NULL,
    [RegrindCyclones] varchar NOT NULL,
    [MediaSkips] varchar NOT NULL,
    [Vertimills] varchar NOT NULL,
    [InspectionComment] varchar NOT NULL,
    [CreatedBy] char(10) NOT NULL,
    [UtcCreatedDate] datetime NOT NULL,
    [ModifiedBy] char(10) NOT NULL,
    [UtcModifiedDate] datetime NOT NULL
);