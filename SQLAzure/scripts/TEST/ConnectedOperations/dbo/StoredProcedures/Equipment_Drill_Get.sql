






/******************************************************************  
* PROCEDURE	: dbo.Equipment_Drill_Get
* PURPOSE	: 
* NOTES		: 
* CREATED	: jrodulfa, 24 Feb 2023
* SAMPLE	: 
	1. EXEC dbo.Equipment_Drill_Get 'PREV', 'TYR'
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {24 Feb 2023}		{jrodulfa}		{Initial Created}
* {05 Feb 2023}		{jrodulfa}		{Updated returned columns}
* {26 Oct 2023}		{lwasini}		{Add Asset Efficiency}
* {12 Jan 2024}		{lwasini}		{Add TYR}
* {23 Jan 2024}     {lwasini}		{Add ABR}
*******************************************************************/ 
CREATE PROCEDURE [dbo].[Equipment_Drill_Get] 
(	
	@SHIFT VARCHAR(4),
	@SITE VARCHAR(4)
	--@STATUS NVARCHAR(MAX)
	--@EQMT NVARCHAR(MAX)
)
AS                        
BEGIN          
	
	SET @SITE = CASE @SITE
					WHEN 'SAM' THEN 'SAF'
					WHEN 'CVE' THEN 'CER'
					WHEN 'CHN' THEN 'CHI'
					ELSE @SITE
				END;

	IF @SITE = 'BAG'
	BEGIN
		SELECT [DRILL_ID] AS [Name],
			   [PATTERN_NO] AS [Location],
			   [OperatorName],
			   [OperatorImageURL] as ImageUrl,
			   ROUND([Feet_Drilled], 0) AS FeetDrilledActual,
			   ROUND([Feet_Drilled_Target], 0) AS FeetDrilledTarget,
			   ROUND([Holes_Drilled], 1) AS HolesDrilledActual,
			   ROUND([Hole_Drilled_Target], 0) AS HolesDrilledTarget,
			   ROUND([XY_Drill_Score], 2) AS XyDrillScoreActual,
			   0 AS XyDrillScoreTarget,
			   [Depth_Drill_Score] AS [DepthDrillScoreActual],
			   0 AS [DepthDrillScoreTarget],
			   [OVERALLSCORE] AS [PerformanceMatrixActual],
			   0 AS [PerformanceMatrixTarget],
			   ROUND([Over_Drill], 2) AS OverDrilledActual,
			   0 AS OverDrilledTarget,
			   ROUND([Under_Drill], 2) AS UnderDrilledActual,
			   0 AS UnderDrilledTarget,
			   ROUND([Avg_Time_Between_Holes], 2) AS AvgTimeBnHolesActual,
			   0 AS AvgTimeBnHolesTarget,
			   ROUND([Average_HoleTime], 2) AS AvgDrillingTimeActual,
			   0 AS AvgDrillingTimeTarget,
			   ROUND([Average_Pen_Rate], 2) AS PenetrationRateActual,
			   PenetrationRateTarget,
			   [Average_First_Drill] AS AvgFirstDrillActual,
			   NULL AS AvgFirstDrillTarget,
			   [Average_Last_Drill] AS AvgLastDrillActual,
			   NULL AS AvgLastDrillTarget,
			   ROUND([Average_GPS_Quality], 0) AS GPSQualityActual,
			   0 AS [GPSQualityTarget],
			   ROUND([UofA], 0) AS AvgUseofAvailActual,
			   ROUND([DRILLUTILIZATION], 2) AS AvgUseofAvailTarget,
			   ROUND([Avail], 2) AS AvailabilityActual,
			   ROUND([DRILLAVAILABILITY], 2) AS AvailabilityTarget,
			   ROUND([AssetEfficiency], 2) AS AssetEfficiencyActual,
			   ROUND([AssetEfficiencyTarget], 2) AS AssetEfficiencyTarget,
			   reasons AS Reason,
			   reasonidx AS ReasonIdx,
			   [Duration] / 60.00 AS TimeInState,
			   [MODEL],
			   eqmtcurrstatus
		FROM [BAG].[CONOPS_BAG_DRILL_DETAIL_V]
		WHERE shiftflag = @SHIFT ;
		--AND siteflag = @SITE
		--AND (eqmtcurrstatus IN (SELECT TRIM(value) FROM STRING_SPLIT(UPPER(@STATUS ), ',')) OR ISNULL(@STATUS, '') = '')
	END

	ELSE IF @SITE = 'CER'
	BEGIN
		SELECT [DRILL_ID] AS [Name],
			   [PATTERN_NO] AS [Location],
			   [OperatorName],
			   [OperatorImageURL] as ImageUrl,
			   ROUND([Feet_Drilled], 0) AS FeetDrilledActual,
			   ROUND([Feet_Drilled_Target], 0) AS FeetDrilledTarget,
			   ROUND([Holes_Drilled], 1) AS HolesDrilledActual,
			   ROUND([Hole_Drilled_Target], 0) AS HolesDrilledTarget,
			   ROUND([XY_Drill_Score], 2) AS XyDrillScoreActual,
			   0 AS XyDrillScoreTarget,
			   [Depth_Drill_Score] AS [DepthDrillScoreActual],
			   0 AS [DepthDrillScoreTarget],
			   [OVERALLSCORE] AS [PerformanceMatrixActual],
			   0 AS [PerformanceMatrixTarget],
			   ROUND([Over_Drill], 2) AS OverDrilledActual,
			   0 AS OverDrilledTarget,
			   ROUND([Under_Drill], 2) AS UnderDrilledActual,
			   0 AS UnderDrilledTarget,
			   ROUND([Avg_Time_Between_Holes], 2) AS AvgTimeBnHolesActual,
		