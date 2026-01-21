CREATE VIEW [CLI].[CONOPS_CLI_TRUCK_TPRH] AS




--select * from [cli].[CONOPS_CLI_TRUCK_TPRH] WITH(NOLOCK)
CREATE VIEW [cli].[CONOPS_CLI_TRUCK_TPRH] 
AS

	SELECT [th].[ShiftId],
		   [th].[Truck],
		   [th].tonsHaul
	FROM (
		SELECT [sd].ShiftId,
			   [sd].[siteflag],
			   [t].FieldId [Truck],
			   COALESCE(SUM([sd].FieldTons), 0) [tonsHaul]
		FROM [cli].[shift_dump] [sd] WITH(NOLOCK)
		LEFT JOIN [cli].[shift_eqmt] [t] WITH(NOLOCK)
		ON [sd].FieldTruck = [t].id
		GROUP BY [sd].ShiftId, [t].FieldId,[sd].[siteflag]
	) [th]


