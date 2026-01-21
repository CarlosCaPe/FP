CREATE VIEW [chi].[ZZZ_CONOPS_CHI_TRUCK_TPRH_OLD] AS




--select * from [chi].[CONOPS_CHI_TRUCK_TPRH] WITH(NOLOCK)
CREATE VIEW [chi].[CONOPS_CHI_TRUCK_TPRH_OLD] 
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
		FROM [chi].SHIFT_DUMP sd WITH (NOLOCK)
		LEFT JOIN [chi].[shift_eqmt] [t] WITH(NOLOCK)
		ON [sd].FieldTruck = [t].Id
		WHERE [t].FieldId IS NOT NULL
		GROUP BY [sd].ShiftId, [t].FieldId,[sd].[siteflag]
	) [th]
	ON [shift].shiftid = [th].ShiftId
	   AND [shift].[siteflag] = [th].[siteflag]
	WHERE [shift].[siteflag] = 'CHI'

