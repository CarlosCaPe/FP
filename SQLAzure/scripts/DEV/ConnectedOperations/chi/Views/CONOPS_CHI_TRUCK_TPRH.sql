CREATE VIEW [chi].[CONOPS_CHI_TRUCK_TPRH] AS



--select * from [chi].[CONOPS_CHI_TRUCK_TPRH] WITH(NOLOCK)
CREATE VIEW [chi].[CONOPS_CHI_TRUCK_TPRH] 
AS

	SELECT [th].[ShiftId],
		   [th].[Truck],
		   [th].tonsHaul
	FROM (
		SELECT [sd].ShiftId,
			   [sd].[siteflag],
			   [t].FieldId [Truck],
			   COALESCE(SUM([sd].FieldTons), 0) [tonsHaul]
		FROM [chi].[shift_dump] [sd] WITH(NOLOCK)
		LEFT JOIN [chi].[shift_eqmt] [t] WITH(NOLOCK)
		ON [sd].FieldTruck = [t].id
		GROUP BY [sd].ShiftId, [t].FieldId,[sd].[siteflag]
	) [th]

