CREATE TABLE [mill].[Kpis] (
    [KpiId] varchar(8) NOT NULL,
    [SiteCode] varchar(3) NOT NULL,
    [ProcessId] varchar(3) NOT NULL,
    [SubProcessId] varchar(3) NOT NULL,
    [KpiGroupId] varchar(8) NOT NULL,
    [KpiUiType] varchar(8) NOT NULL,
    [KpiName] varchar(64) NOT NULL,
    [KpiSensorId] varchar(48) NOT NULL,
    [IsAllowNegativeValue] bit NOT NULL,
    [KpiUnit] varchar(16) NOT NULL,
    [DisplayOrder] tinyint NOT NULL,
    [CreatedBy] char(10) NOT NULL,
    [UtcCreatedDate] datetime NOT NULL,
    [ModifiedBy] char(10) NOT NULL,
    [UtcModifiedDate] datetime NOT NULL
);