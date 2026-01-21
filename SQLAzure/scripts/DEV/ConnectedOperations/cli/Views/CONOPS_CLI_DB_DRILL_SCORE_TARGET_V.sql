CREATE VIEW [cli].[CONOPS_CLI_DB_DRILL_SCORE_TARGET_V] AS

--select * from [cli].[CONOPS_CLI_DB_DRILL_SCORE_TARGET_V] where shiftflag = 'curr'
CREATE VIEW [cli].[CONOPS_CLI_DB_DRILL_SCORE_TARGET_V]
AS

SELECT CAST(Right([Year], 2) + FORMAT(CAST([Month] AS numeric), '00') +
		FORMAT(CAST([Day] AS numeric), '00') + FORMAT(CAST(SHIFT_CODE AS numeric), '000') AS numeric) [ShiftId],
	   'CMX' [siteflag],
	   [DRILLAVAILABILITY],
	   [DRILLASSETEFFICIENCY],
	   [DRILLUTILIZATION],
	   TARGETFEETDRILLED,
	   TARGETHOLESDRILLED
FROM (
	SELECT REVERSE(PARSENAME(REPLACE(REVERSE([ShiftId]), '/', '.'), 1)) AS [Month],
		   REVERSE(PARSENAME(REPLACE(REVERSE([ShiftId]), '/', '.'), 2)) AS [Day],
		   LEFT(REVERSE(PARSENAME(REPLACE(REVERSE([ShiftId]), '/', '.'), 3)), 4) AS [Year],
		   REVERSE(PARSENAME(REPLACE(REVERSE([ShiftId]), '-', '.'), 2)) AS SHIFT_CODE,
		   0 AS [DRILLAVAILABILITY],
		   0 AS [DRILLASSETEFFICIENCY],
		   0 AS [DRILLUTILIZATION],
		   FeetDrilled AS TARGETFEETDRILLED,
		   HolesDrilled AS TARGETHOLESDRILLED
    FROM [cli].[PLAN_VALUES] (NOLOCK)
) [target]

