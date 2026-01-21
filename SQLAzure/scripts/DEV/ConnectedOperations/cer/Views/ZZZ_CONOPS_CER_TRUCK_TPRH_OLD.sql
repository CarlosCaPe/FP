CREATE VIEW [cer].[ZZZ_CONOPS_CER_TRUCK_TPRH_OLD] AS




--select * from [cer].[CONOPS_CER_TRUCK_TPRH] WITH(NOLOCK)
CREATE VIEW [cer].[CONOPS_CER_TRUCK_TPRH_OLD]
AS

	SELECT [shift].shiftflag,
		   [shift].[siteflag],
		   [th].[Truck],
		   [th].tonsHaul,
		   [shift].ShiftDuration
	FROM [dbo].[SHIFT_INFO_V] [shift] WITH(NOLOCK)
	LEFT JOIN (
		SELECT [sd].ShiftId,
			   'CER' [siteflag],
			   [t].FieldId [Truck],
			   COALESCE(SUM([sd].FieldTons), 0) [tonsHaul]
		FROM [cer].[shift_dump] [sd] WITH(NOLOCK)
		LEFT JOIN [cer].[shift_eqmt] [t] WITH(NOLOCK)
		ON [sd].FieldTruck = [t].shift_eqmt_id
		GROUP BY [sd].ShiftId, [t].FieldId
	) [th]
	ON [shift].shiftid = [th].ShiftId
	   AND [shift].[siteflag] = [th].[siteflag]
	WHERE [shift].[siteflag] = 'CER'

