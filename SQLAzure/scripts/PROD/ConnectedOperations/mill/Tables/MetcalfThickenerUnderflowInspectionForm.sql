CREATE TABLE [mill].[MetcalfThickenerUnderflowInspectionForm] (
    [TransactionId] int NOT NULL,
    [SiteCode] varchar(3) NOT NULL,
    [TransactionDate] datetime NOT NULL,
    [RawData] varchar NOT NULL,
    [5010Thickener] varchar NOT NULL,
    [5011Thickener] varchar NOT NULL,
    [InspectionComment] varchar NOT NULL,
    [CreatedBy] char(10) NOT NULL,
    [UtcCreatedDate] datetime NOT NULL,
    [ModifiedBy] char(10) NOT NULL,
    [UtcModifiedDate] datetime NOT NULL
);