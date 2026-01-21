CREATE VIEW [TYR].[CONOPS_TYR_DB_DRILL_SCORE_TARGET_V] AS



--select * from [tyr].[CONOPS_TYR_DB_DRILL_SCORE_TARGET_V]where shiftflag = 'curr'
CREATE VIEW [tyr].[CONOPS_TYR_DB_DRILL_SCORE_TARGET_V]
AS
/*
SELECT CAST(Right([Year], 2) + FORMAT(CAST([Month] AS numeric), '00') AS numeric) [ShiftId],
	   [siteflag],
	   TARGETFEETDRILLED,
	   TARGETHOLESDRILLED
FROM (
	SELECT REVERSE(PARSENAME(REPLACE(REVERSE([EFFECTIVEDATE]), '-', '.'), 1)) AS [Year],
		   REVERSE(PARSENAME(REPLACE(REVERSE([EFFECTIVEDATE]), '-', '.'), 2)) AS [Month],
		   REVERSE(PARSENAME(REPLACE(REVERSE([EFFECTIVEDATE]), '-', '.'), 3)) AS [Day],
		   [siteflag],
		   CAST([PlannedHoles]/2 AS INT) * 55 AS TARGETFEETDRILLED,
		   CAST([PlannedHoles]/2 AS INT) AS TARGETHOLESDRILLED
    FROM [tyr].[plan_values_monthly_drilling] (NOLOCK)
) [target]*/

SELECT
NULL AS ShiftId,
NULL AS siteflag,
0 AS TARGETFEETDRILLED,
0 AS TARGETHOLESDRILLED


