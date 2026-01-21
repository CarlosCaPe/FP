CREATE VIEW [mor].[ZZZ_CONOPS_MOR_MATERIAL_DELIVERED_TO_CHRUSHER_TARGET_V_OLD] AS









--select * from [mor].[CONOPS_MOR_MATERIAL_DELIVERED_TO_CHRUSHER_TARGET_V] WITH (NOLOCK)

CREATE VIEW [mor].[CONOPS_MOR_MATERIAL_DELIVERED_TO_CHRUSHER_TARGET_V_OLD] 
AS
	WITH stc AS
	(
	    SELECT FormatShiftid as shiftid,
			   SUM(CAST(REPLACE(Tons, ',', '') as float)) [total]
		FROM [mor].[plan_values] (nolock)
		WHERE Destination = 'STC9999'
		GROUP BY FormatShiftid
	),
	ip AS
	(
	    SELECT FormatShiftid as shiftid,
			   SUM(CAST(REPLACE(Tons, ',', '') as float)) [total]
		FROM [mor].[plan_values] (nolock)
		WHERE Destination = 'IPC3M'
		GROUP BY FormatShiftid
	)

	SELECT [shift].shiftflag,
	       [shift].[siteflag],
		   [Location],
		   [Target]
	FROM [dbo].[SHIFT_INFO_V] [shift] WITH (NOLOCK)
	LEFT JOIN (
		SELECT stc.[ShiftID],
			   --'MOR' [siteflag],
			   'Crusher 2' [Location], 
			   [stc].total + ((0.1*([stc].total + ip.total)) * ([stc].total/([stc].total + ip.total))) [Target]
		FROM stc
		LEFT JOIN ip
		ON stc.[ShiftID] = ip.[ShiftID]
	) [C2]
	ON [C2].[ShiftID] = [shift].[ShiftID] AND [shift].[siteflag] = 'MOR'
	WHERE [shift].[siteflag] = 'MOR'
	UNION ALL
	SELECT [shift].shiftflag,
	       [shift].[siteflag],
		   [Location],
		   [Target]
	FROM [dbo].[SHIFT_INFO_V] [shift] WITH (NOLOCK)
	LEFT JOIN (
		SELECT [ip].[ShiftID],
			   --'MOR' [siteflag],
			   'Crusher 3' [Location], 
			   [ip].total + ((0.1*([stc].total + ip.total)) * ([ip].total/([stc].total + [ip].total))) [Target]
		FROM [ip]
		LEFT JOIN stc
		ON stc.[ShiftID] = [ip].[ShiftID]
	) [C3]
	ON [C3].[ShiftID] = [shift].[ShiftID] AND [shift].[siteflag] = 'MOR'
	WHERE [shift].[siteflag] = 'MOR'

