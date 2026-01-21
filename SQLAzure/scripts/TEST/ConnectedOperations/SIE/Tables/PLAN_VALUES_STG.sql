CREATE TABLE [SIE].[PLAN_VALUES_STG] (
    [ShovelName] varchar(100) NOT NULL,
    [PushbackName] varchar(100) NOT NULL,
    [BenchName] varchar(100) NOT NULL,
    [PolygonName] varchar(100) NOT NULL,
    [Destination] varchar(100) NOT NULL,
    [ShiftID] datetime NOT NULL,
    [Mass_Tons] decimal(18,5) NULL,
    [Grade_ASCu] decimal(18,5) NULL,
    [Grade_EqCu] decimal(18,5) NULL,
    [Grade_Mo] decimal(18,5) NULL,
    [Grade_TCu] decimal(18,5) NULL,
    [EarliestStartDate] datetime NULL,
    [LatestFinishDate] datetime NULL,
    [ProductiveHours] decimal(18,5) NULL
);