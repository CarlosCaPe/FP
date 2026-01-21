CREATE VIEW [saf].[CONOPS_SAF_MINE_PRODUCTIVITY_V] AS




--select * from [saf].[CONOPS_SAF_MINE_PRODUCTIVITY_V] WITH (NOLOCK)
CREATE VIEW [saf].[CONOPS_SAF_MINE_PRODUCTIVITY_V]
AS


WITH TONS AS (
	SELECT shiftid,
		   SUM(totalmineralsmined) as totalmineralsmined
	FROM [saf].[CONOPS_SAF_SHIFT_OVERVIEW_V] WITH (NOLOCK)
	GROUP BY shiftid
),

TGT AS (
	SELECT --shiftflag,
		   CAST(Right([Year], 2) + FORMAT(CAST([Month] AS numeric), '00') +
				FORMAT(CAST([Day] AS numeric), '00') + FORMAT(CAST(SHIFT_CODE AS numeric), '000') AS numeric) [ShiftId],
		   [target]
	FROM (
		SELECT  --'SAF' shiftflag,
				REVERSE(PARSENAME(REPLACE(REVERSE(DATEEFFECTIVE), '-', '.'), 1)) AS [Year],
				REVERSE(PARSENAME(REPLACE(REVERSE(DATEEFFECTIVE), '-', '.'), 2)) AS [Month],
				REVERSE(PARSENAME(REPLACE(REVERSE(DATEEFFECTIVE), '-', '.'), 3)) AS [Day],
				Shiftindex AS [SHIFT_CODE],
				TOTALMINETPD as [target]
		FROM saf.PLAN_VALUES WITH (NOLOCK)
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
FROM saf.CONOPS_SAF_SHIFT_INFO_V a
LEFT JOIN TONS tn on a.shiftid = tn.shiftid AND a.siteflag = 'SAF'
LEFT JOIN TGT tg on a.shiftid = tg.shiftid AND a.siteflag = 'SAF'
WHERE a.siteflag = 'SAF'

