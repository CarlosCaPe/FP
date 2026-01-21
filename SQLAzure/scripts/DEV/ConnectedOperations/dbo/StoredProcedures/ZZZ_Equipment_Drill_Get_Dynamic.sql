
/******************************************************************  
* PROCEDURE	: dbo.Equipment_Drill_Get
* PURPOSE	: 
* NOTES		: 
* CREATED	: jrodulfa, 24 Feb 2023
* SAMPLE	: 
	1. EXEC dbo.Equipment_Drill_Get 'PREV', 'SAM', NULL
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {24 Feb 2023}		{jrodulfa}		{Initial Created}}
*******************************************************************/ 
CREATE PROCEDURE [dbo].[Equipment_Drill_Get] 
(	
	@SHIFT VARCHAR(4),
	@SITE VARCHAR(4),
	@STATUS NVARCHAR(MAX)
	--@EQMT NVARCHAR(MAX)
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
			   [PATTERN_NO] AS [Location],
			   [OperatorName],
			   [OperatorImageURL] as ImageUrl,
			   ROUND([Holes_Drilled], 1) AS HolesDrilledActual,
			   ROUND([Hole_Drilled_Target], 0) AS HolesDrilledTarget,
			   [OVERALLSCORE] AS [PerformanceMatrixActual],
			   0 AS [PerformanceMatrixTarget],
			   ROUND([Average_Pen_Rate], 2) AS PenetrationRateActual,
			   PenetrationRateTarget,
			   ROUND([Total_Depth], 2) AS TotalDrillDepthActual,
			   0 AS TotalDrillDepthTarget,
			   ROUND([Average_GPS_Quality], 0) AS GPSQualityActual,
			   0 AS [GPSQualityTarget],
			   ROUND([UofA], 2) AS AvgUseofAvailActual,
			   ROUND([DRILLUTILIZATION], 2) AS AvgUseofAvailTarget,
			   ROUND([Feet_Drilled], 0) AS FeetDrilledActual,
			   ROUND([Feet_Drilled_Target], 0) AS FeetDrilledTarget,
			   ROUND([XY_Drill_Score], 0) AS XyDrillScoreActual,
			   0 AS XyDrillScoreTarget,
			   ROUND([Over_Drill], 0) AS OverDrilledActual,
			   0 AS OverDrilledTarget,
			   ROUND([Under_Drill], 0) AS UnderDrilledActual,
			   0 AS UnderDrilledTarget,
			   ROUND([Avg_Time_Between_Holes], 2) AS AvgTimeBnHolesActual,
			   0 AS AvgTimeBnHolesTarget,
			   ROUND([Average_First_Last_Drill], 2) AS AvgFirstLastDrillActual,
			   0 AS AvgFirstLastDrillTarget,
			   ROUND([Average_HoleTime], 2) AS AvgDrillingTimeActual,
			   0 AS AvgDrillingTimeTarget,
			   reasons AS Reason,
			   reasonidx AS ReasonIdx,
			   [Duration] AS TimeInState,
			   [MODEL],
			   eqmtcurrstatus
		FROM [' + @SCHEMA + '].[CONOPS_' + @SCHEMA + '_DRILL_DETAIL_V]
		WHERE shiftflag = ''' + @SHIFT + '''
		AND siteflag = ''' + @SITE + '''
		AND (eqmtcurrstatus IN (SELECT TRIM(value) FROM STRING_SPLIT(UPPER(''' + @STATUS + '''), '','')) OR ISNULL(''' + @STATUS + ''', '''') = '''')
	');

SET NOCOUNT OFF
END

