CREATE VIEW [CHI].[CONOPS_CHI_MINE_PRODUCTIVITY_V] AS






--select * from [chi].[CONOPS_CHI_MINE_PRODUCTIVITY_V] WITH (NOLOCK)
CREATE VIEW [chi].[CONOPS_CHI_MINE_PRODUCTIVITY_V]
AS


WITH TONS AS (
	SELECT shiftid,
		   SUM(TotalMaterialMined) as totalmineralsmined
	FROM [chi].[CONOPS_CHI_SHIFT_OVERVIEW_V] WITH (NOLOCK)
	GROUP BY shiftid
),

TGT AS (
	SELECT --siteflag,
		   CAST(Right([Year], 2) + FORMAT(CAST([Month] AS numeric), '00') AS numeric) [ShiftId],
		   [target]
	FROM (
		SELECT  --'CHI' siteflag,
				REVERSE(PARSENAME(REPLACE(REVERSE(DATEEFFECTIVE), '-', '.'), 1)) AS [Year],
				REVERSE(PARSENAME(REPLACE(REVERSE(DATEEFFECTIVE), '-', '.'), 2)) AS [Month],
				(ISNULL([TotalExPitTPD], 0)  + ISNULL([OreRehandletoCrusherTPD], 0)) / 2 as [target]
		FROM CHI.PLAN_VALUES tgt WITH (NOLOCK)
		INNER JOIN (
			SELECT MAX(DATEEFFECTIVE) MaxDateEffective
			FROM [chi].[PLAN_VALUES] WITH (NOLOCK)
			WHERE GETDATE() >= DateEffective 
		 ) [maxdate] ON tgt.DateEffective = [maxdate].MaxDateEffective
	) a
)

SELECT a.shiftflag,
	   a.siteflag,
	   a.shiftid,
	   tn.totalmineralsmined,
	   tg.[target],
	   FLOOR(a.ShiftDuration / 3600) shiftcompletehour,
	   CASE WHEN FLOOR(a.ShiftDuration / 3600) > 0
			THEN tn.totalmineralsmined/FLOOR(a.ShiftDuration / 3600)
			ELSE 0
	   END AS mineproductivity,
	   tg.[target]/12.0 AS mineproductivitytarget
FROM chi.CONOPS_CHI_SHIFT_INFO_V a
LEFT JOIN TONS tn on a.shiftid = tn.shiftid AND a.siteflag = 'CHI'
LEFT JOIN TGT tg on LEFT(a.shiftid, 4) >= tg.shiftid AND a.siteflag = 'CHI'
WHERE a.siteflag = 'CHI'


