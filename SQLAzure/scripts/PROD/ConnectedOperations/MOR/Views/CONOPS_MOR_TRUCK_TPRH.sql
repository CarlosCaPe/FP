CREATE VIEW [MOR].[CONOPS_MOR_TRUCK_TPRH] AS



--select * from [mor].[CONOPS_MOR_TRUCK_TPRH] WITH(NOLOCK)
CREATE VIEW [mor].[CONOPS_MOR_TRUCK_TPRH] 
AS

	
	SELECT [th].[ShiftId],
		   [th].[Truck],
		   [th].tonsHaul
	FROM (
		SELECT [sd].ShiftId,
			   [sd].[siteflag],
			   [t].FieldId [Truck],
			   COALESCE(SUM([sd].FieldTons), 0) [tonsHaul]
		FROM [mor].[shift_dump] [sd] WITH(NOLOCK)
		LEFT JOIN [mor].[shift_eqmt] [t] WITH(NOLOCK)
		ON [sd].FieldTruck = [t].Id
		GROUP BY [sd].ShiftId, [t].FieldId,[sd].[siteflag]
	) [th]

	
	



