CREATE VIEW [CER].[CONOPS_CER_TRUCK_TPRH] AS



--select * from [cer].[CONOPS_CER_TRUCK_TPRH] WITH(NOLOCK)
CREATE VIEW [cer].[CONOPS_CER_TRUCK_TPRH]
AS

	SELECT [th].[ShiftId],
		   [th].[Truck],
		   [th].tonsHaul
	FROM (
		SELECT [sd].ShiftId,
			   [sd].[siteflag],
			   [t].FieldId [Truck],
			   COALESCE(SUM([sd].FieldTons), 0) [tonsHaul]
		FROM [cer].[shift_dump] [sd] WITH(NOLOCK)
		LEFT JOIN [cer].[shift_eqmt] [t] WITH(NOLOCK)
		ON [sd].FieldTruck = [t].shift_eqmt_id
		GROUP BY [sd].ShiftId, [t].FieldId,[sd].[siteflag]
	) [th]

