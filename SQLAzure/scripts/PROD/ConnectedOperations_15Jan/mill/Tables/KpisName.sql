CREATE TABLE [mill].[KpisName] (
    [KpiId] varchar(8) NOT NULL,
    [LanguageCode] varchar(5) NOT NULL,
    [KpiName] varchar(64) NOT NULL,
    [KpiUnit] varchar(16) NOT NULL,
    [CreatedBy] char(10) NOT NULL,
    [UtcCreatedDate] datetime NOT NULL,
    [ModifiedBy] char(10) NOT NULL,
    [UtcModifiedDate] datetime NOT NULL
);