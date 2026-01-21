CREATE VIEW [saf].[ZZZ_CONOPS_SAF_TRUCK_TPRH_OLD] AS





--select * from [saf].[CONOPS_SAF_TRUCK_TPRH] WITH(NOLOCK)
CREATE VIEW [saf].[CONOPS_SAF_TRUCK_TPRH_OLD] 
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
		FROM [saf].SHIFT_DUMP sd WITH (NOLOCK)
		LEFT JOIN [saf].[shift_eqmt] [t] WITH(NOLOCK)
		ON [sd].FieldTruck = [t].Id
		WHERE [t].FieldId IS NOT NULL
		GROUP BY [sd].ShiftId, [t].FieldId,[sd].[siteflag]
	) [th]
	ON [shift].shiftid = [th].ShiftId
	   AND [shift].[siteflag] = [th].[siteflag]
	WHERE [shift].[siteflag] = 'SAF'

