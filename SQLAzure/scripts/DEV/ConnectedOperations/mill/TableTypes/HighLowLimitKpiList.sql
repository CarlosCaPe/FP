CREATE TYPE [mill].[HighLowLimitKpiList] AS TABLE (
    [KpiId] varchar(8) NOT NULL,
    [MinValue] decimal(18,2) NOT NULL,
    [MaxValue] decimal(18,2) NOT NULL
);