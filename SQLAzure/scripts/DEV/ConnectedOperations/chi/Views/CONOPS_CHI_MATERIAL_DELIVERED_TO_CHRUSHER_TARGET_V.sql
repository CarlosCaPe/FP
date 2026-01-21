CREATE VIEW [chi].[CONOPS_CHI_MATERIAL_DELIVERED_TO_CHRUSHER_TARGET_V] AS




--select * from [chi].[CONOPS_CHI_MATERIAL_DELIVERED_TO_CHRUSHER_TARGET_V] WITH (NOLOCK)
CREATE VIEW [chi].[CONOPS_CHI_MATERIAL_DELIVERED_TO_CHRUSHER_TARGET_V] 
AS
	WITH crusherTarget AS (
		SELECT Right([Year], 2) + FORMAT(CAST([Month] AS numeric), '00') [ShiftId],
			   [siteflag],
			   [TotalMaterialtoCrusher] / 2 as [Target]
		FROM (
			SELECT DATEEFFECTIVE,
				   REVERSE(PARSENAME(REPLACE(REVERSE(DATEEFFECTIVE), '-', '.'), 1)) AS [Year],
				   REVERSE(PARSENAME(REPLACE(REVERSE(DATEEFFECTIVE), '-', '.'), 2)) AS [Month],
				   REVERSE(PARSENAME(REPLACE(REVERSE(DATEEFFECTIVE), '-', '.'), 3)) AS [Day],
				   siteflag,
				   [TotalMaterialtoCrusher]
			FROM [chi].[PLAN_VALUES] pv (nolock)
			INNER JOIN (
				SELECT MAX(DATEEFFECTIVE) MaxDateEffective
				FROM [chi].[PLAN_VALUES] WITH (NOLOCK)
				WHERE GETDATE() >= DateEffective 
			) [maxdate] ON [pv].DateEffective = [maxdate].MaxDateEffective
		) a
	)

	SELECT [shift].shiftflag,
	       [shift].[siteflag],
		   [shift].shiftid,
		   'CRUSHER' [Location],
		   [Target]
	FROM [CHI].[CONOPS_CHI_SHIFT_INFO_V] [shift] WITH (NOLOCK)
	LEFT JOIN crusherTarget [C2]
	ON LEFT([shift].[ShiftID], 4) >= [C2].[ShiftId] AND [C2].[siteflag] = [shift].[siteflag]
	WHERE [C2].[siteflag] = 'CHI'


