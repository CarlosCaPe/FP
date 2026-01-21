CREATE VIEW [mor].[ZZZ_CONOPS_MOR_TRUCK_TPRH_OLD] AS




--select * from [mor].[CONOPS_MOR_TRUCK_TPRH] WITH(NOLOCK)
CREATE VIEW [mor].[CONOPS_MOR_TRUCK_TPRH_OLD] 
AS

	SELECT [shift].shiftflag,
		   [shift].[siteflag],
		   [th].[Truck],
		   [th].tonsHaul,
		   [shift].ShiftDuration
	FROM [dbo].[SHIFT_INFO_V] [shift] WITH(NOLOCK)
	LEFT JOIN (
		SELECT [sd].ShiftId,
			   [sd].[siteflag],
			   [t].FieldId [Truck],
			   COALESCE(SUM([sd].FieldTons), 0) [tonsHaul]
		FROM [mor].[shift_dump] [sd] WITH(NOLOCK)
		LEFT JOIN [mor].[shift_eqmt] [t] WITH(NOLOCK)
		ON [sd].FieldTruck = [t].Id
		GROUP BY [sd].ShiftId, [t].FieldId,[sd].[siteflag]
	) [th]
	ON [shift].shiftid = [th].ShiftId
	   AND [shift].[siteflag] = [th].[siteflag]
	WHERE [shift].[siteflag] = 'MOR'

