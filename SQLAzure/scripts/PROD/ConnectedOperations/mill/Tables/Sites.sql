CREATE TABLE [mill].[Sites] (
    [SiteCode] varchar(3) NOT NULL,
    [SiteName] varchar(20) NOT NULL,
    [IsEnabled] bit NOT NULL,
    [CreatedBy] varchar(10) NOT NULL,
    [UtcCreatedDate] datetime NOT NULL,
    [ModifiedBy] varchar(10) NOT NULL,
    [UtcModifiedDate] datetime NOT NULL
);