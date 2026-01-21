
/******************************************************************  
* PROCEDURE	: dbo.Equipment_DrillMatrixDrillDown_Get
* PURPOSE	: 
* NOTES		: 
* CREATED	: jrodulfa, 21 Mar 2023
* SAMPLE	: 
	1. EXEC dbo.Equipment_DrillMatrixDrillDown_Get 'PREV', 'MOR', '12R'
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {21 Mar 2023}		{jrodulfa}		{Initial Created}}
*******************************************************************/ 
CREATE PROCEDURE [dbo].[Equipment_DrillMatrixDrillDown_Get] 
(	
	@SHIFT VARCHAR(4),
	@SITE VARCHAR(4),
	--@STATUS NVARCHAR(MAX),
	@EQMT NVARCHAR(MAX)
)
AS                        
BEGIN          
	
	DECLARE @SCHEMA VARCHAR(4);

	SET @SITE = CASE @SITE
					WHEN 'SAM' THEN 'SAF'
					WHEN 'CVE' THEN 'CER'
					WHEN 'CHN' THEN 'CHI'
					ELSE @SITE
				END;

	SET @SCHEMA = CASE @SITE 
					   WHEN 'CMX' THEN 'CLI'
					   ELSE @SITE
				  END;

	EXEC('
		SELECT [DRILL_ID] AS [Name],
			   [OperatorName],
			   [OperatorImageURL] as ImageUrl,
			   reasonidx AS ReasonIdx,
			   [PATTERN_NO] AS [Location],
			   [Duration] AS TimeInState,
			   [MODEL],
			   [CREW],
			   ROUND([Feet_Drilled], 0) AS FeetDrilledActual,
			   ROUND([Feet_Drilled_Target], 0) AS FeetDrilledTarget,
			   ROUND([Average_Pen_Rate], 2) AS PenetrationRateActual,
			   PenetrationRateTarget,
			   ROUND([Holes_Drilled], 1) AS HolesDrilledActual,
			   ROUND([Hole_Drilled_Target], 0) AS HolesDrilledTarget,
			   ROUND([Total_Depth], 2) AS TotalDrillDepthActual,
			   0 AS TotalDrillDepthTarget,
			   ROUND([UofA], 2) AS AvgUseofAvailActual,
			   ROUND([DRILLUTILIZATION], 2) AS AvgUseofAvailTarget,
			   ROUND([Average_GPS_Quality], 0) AS GPSQualityActual,
			   0 AS [GPSQualityTarget],
			   ROUND([Avg_Time_Between_Holes], 2) AS AvgTimeBnHolesActual,
			   0 AS AvgTimeBnHolesTarget,
			   ROUND([Average_First_Last_Drill], 2) AS AvgFirstLastDrillActual,
			   0 AS AvgFirstLastDrillTarget,
			   ROUND([Average_HoleTime], 2) AS AvgDrillingTimeActual,
			   0 AS AvgDrillingTimeTarget,
			   ROUND([XY_Drill_Score], 2) AS XyDrillScoreActual,
			   0 AS XyDrillScoreTarget,
			   ROUND([Over_Drill], 2) AS OverDrilledActual,
			   0 AS OverDrilledTarget,
			   ROUND([Under_Drill], 2) AS UnderDrilledActual,
			   0 AS UnderDrilledTarget
		FROM [' + @SCHEMA + '].[CONOPS_' + @SCHEMA + '_DRILL_DETAIL_V]
		WHERE shiftflag = ''' + @SHIFT + '''
		AND siteflag = ''' + @SITE + '''
		AND [DRILL_ID] = ''' + @EQMT + ''';

		SELECT Hr,
			   ROUND(ISNULL([Feet_Drilled], 0), 0) AS FeetDrilledActual,
			   ROUND(ISNULL([Average_Pen_Rate], 0), 2) AS PenetrationRateActual,
			   ROUND(ISNULL([Holes_Drilled], 0), 1) AS HolesDrilledActual,
			   ROUND(ISNULL([Total_Depth], 0), 2) AS TotalDrillDepthActual,
			   ROUND(ISNULL([UofA], 0), 2) AS AvgUseofAvailActual,
			   ROUND(ISNULL([Average_GPS_Quality], 0), 0) AS GPSQualityActual,
			   ROUND(ISNULL([Avg_Time_Between_Holes], 0), 2) AS AvgTimeBnHolesActual,
			   ROUND(ISNULL([Average_First_Last_Drill], 0), 2) AS AvgFirstLastDrillActual,
			   ROUND(ISNULL([Average_HoleTime], 0), 2) AS AvgDrillingTimeActual,
			   ROUND(ISNULL([XY_Drill_Score], 0), 2) AS XyDrillScoreActual,
			   ROUND(ISNULL([Over_Drill], 0), 2) AS OverDrilledActual,
			   ROUND(ISNULL([Under_Drill], 0), 2) AS UnderDrilledActual
		FROM [' + @SCHEMA + '].[CONOPS_' + @SCHEMA + '_DRILL_DETAIL_PER_HOUR_V]
		WHERE shiftflag = ''' + @SHIFT + '''
		AND siteflag = ''' + @SITE + '''
		AND [DRILL_ID] = ''' + @EQMT + '''
		ORDER BY HOS;
	');

SET NOCOUNT OFF
END

