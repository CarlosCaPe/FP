CREATE VIEW [SIE].[CONOPS_SIE_TRUCK_TPRH] AS


--select * from [sie].[CONOPS_SIE_TRUCK_TPRH] WITH(NOLOCK)
CREATE VIEW [sie].[CONOPS_SIE_TRUCK_TPRH] 
AS

	SELECT [th].[ShiftId],
		   [th].[Truck],
		   [th].tonsHaul
	FROM (
		SELECT [sd].ShiftId,
			   [sd].[siteflag],
			   [t].FieldId [Truck],
			   COALESCE(SUM([sd].FieldTons), 0) [tonsHaul]
		FROM [sie].[shift_dump] [sd] WITH(NOLOCK)
		LEFT JOIN [sie].[shift_eqmt] [t] WITH(NOLOCK)
		ON [sd].FieldTruck = [t].id
		GROUP BY [sd].ShiftId, [t].FieldId,[sd].[siteflag]
	) [th]

