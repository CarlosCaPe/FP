CREATE VIEW [Arch].[CONOPS_ARCH_TRUCK_TPRH] AS


CREATE VIEW [Arch].[CONOPS_ARCH_TRUCK_TPRH]
AS

	SELECT [shift].shiftflag,
		   [shift].[siteflag],
		   [th].[Truck],
		   [th].tonsHaul,
		   [shift].ShiftDuration
	FROM [dbo].[SHIFT_INFO_V] [shift] WITH(NOLOCK)
	LEFT JOIN (
		SELECT [sd].ShiftId,
			   '<SITECODE>' [siteflag],
			   [t].FieldId [Truck],
			   COALESCE(SUM([sd].FieldTons), 0) [tonsHaul]
		FROM [Arch].SHIFT_DUMP sd WITH (NOLOCK)
		LEFT JOIN [Arch].[shift_eqmt] [t] WITH(NOLOCK)
		ON [sd].FieldTruck = [t].Id
		WHERE [t].FieldId IS NOT NULL
		GROUP BY [sd].ShiftId, [t].FieldId
	) [th]
	ON [shift].shiftid = [th].ShiftId
	   AND [shift].[siteflag] = [th].[siteflag]
	WHERE [shift].[siteflag] = '<SITECODE>'

