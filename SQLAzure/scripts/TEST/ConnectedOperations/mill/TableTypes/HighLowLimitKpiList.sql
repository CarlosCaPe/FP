CREATE TYPE [mill].[HighLowLimitKpiList] AS TABLE (
    [KpiId] nvarchar(100) NOT NULL,
    [MinValue] float NULL,
    [MaxValue] float NULL
);