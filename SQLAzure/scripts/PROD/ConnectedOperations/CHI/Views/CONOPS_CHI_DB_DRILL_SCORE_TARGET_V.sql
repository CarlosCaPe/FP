CREATE VIEW [CHI].[CONOPS_CHI_DB_DRILL_SCORE_TARGET_V] AS




--select * from [chi].[CONOPS_CHI_DB_DRILL_SCORE_TARGET_V] where shiftflag = 'curr'
CREATE VIEW [chi].[CONOPS_CHI_DB_DRILL_SCORE_TARGET_V]
AS

SELECT s.shiftid,
	   s.[siteflag],
	   [DRILLAVAILABILITY],
	   [DRILLASSETEFFICIENCY],
	   [DRILLUTILIZATION],
	   TARGETFEETDRILLED,
	   TARGETHOLESDRILLED
FROM (
	SELECT TOP 1 SITEFLAG,
		   ISNULL([DrillAvailability], 0) AS [DRILLAVAILABILITY],
		   ISNULL([DrillAssetEfficiency], 0) AS [DRILLASSETEFFICIENCY],
		   ISNULL([DrillUtilization], 0) AS [DRILLUTILIZATION],
		   CAST(FeetDrilledDay AS INT)/2 AS TARGETFEETDRILLED,
		   CAST(HolesDrilledDay AS INT)/2 AS TARGETHOLESDRILLED
    FROM [chi].[PLAN_VALUES] (NOLOCK)
	ORDER BY DateEffective DESC
) [target]
RIGHT JOIN CHI.CONOPS_CHI_SHIFT_INFO_V s
	ON s.siteflag = target.siteflag


