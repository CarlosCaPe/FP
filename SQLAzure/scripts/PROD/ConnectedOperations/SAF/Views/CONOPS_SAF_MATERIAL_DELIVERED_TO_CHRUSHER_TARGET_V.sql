CREATE VIEW [SAF].[CONOPS_SAF_MATERIAL_DELIVERED_TO_CHRUSHER_TARGET_V] AS






--select * from [saf].[CONOPS_SAF_MATERIAL_DELIVERED_TO_CHRUSHER_TARGET_V] WITH (NOLOCK)
CREATE VIEW [saf].[CONOPS_SAF_MATERIAL_DELIVERED_TO_CHRUSHER_TARGET_V] 
AS
	WITH crusherTarget AS (
		SELECT Right([Year], 2) + FORMAT(CAST([Month] AS numeric), '00') +
				FORMAT(CAST([Day] AS numeric), '00') + FORMAT(CAST(SHIFT_CODE AS numeric), '000') [ShiftId],
			   [siteflag],
			   [TOTALCRUSHERTPD] as [Target]
		FROM (
			SELECT DATEEFFECTIVE,
				   REVERSE(PARSENAME(REPLACE(REVERSE(DATEEFFECTIVE), '-', '.'), 1)) AS [Year],
				   REVERSE(PARSENAME(REPLACE(REVERSE(DATEEFFECTIVE), '-', '.'), 2)) AS [Month],
				   REVERSE(PARSENAME(REPLACE(REVERSE(DATEEFFECTIVE), '-', '.'), 3)) AS [Day],
				   Shiftindex AS [SHIFT_CODE],
				   siteflag,
				   [TOTALCRUSHERTPD]
			FROM [saf].[PLAN_VALUES] (nolock)
		) a
	)

	SELECT shiftid,
		   'CRUSHER' [Location],
		   [Target]
	FROM crusherTarget [C2]
	


