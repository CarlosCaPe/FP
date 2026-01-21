




/******************************************************************  
* PROCEDURE	: dbo.Equipment_DrillMatrixDrillDown_Get
* PURPOSE	: 
* NOTES		: 
* CREATED	: jrodulfa, 21 Mar 2023
* SAMPLE	: 
	1. EXEC dbo.Equipment_DrillMatrixDrillDown_Get 'PREV', 'BAG'
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {21 Mar 2023}		{jrodulfa}		{Initial Created}
* {19 Apr 2023}		{jrodulfa}		{Make EQMT parameter as Optional Parameter as requested} 
* {12 May 2023}		{jrodulfa}		{Update the field for First/Last Drill Hole}
* {26 Oct 2023}		{lwasini}		{Add Asset Efficiency}
* {12 Jan 2024}		{lwasini}		{Add TYR}
* {23 Jan 2024}     {lwasini}		{Add ABR}
*******************************************************************/ 
CREATE PROCEDURE [dbo].[Equipment_DrillMatrixDrillDown_Get] 
(	
	@SHIFT VARCHAR(4),
	@SITE VARCHAR(4)
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
			   [OperatorName],
			   [OperatorImageURL] as ImageUrl,
			   reasonidx AS ReasonIdx,
			   'Recent operator feedback was submitted, please check employee HR records for details' AS Comment,
			   [PATTERN_NO] AS [Location],
			   [Duration] / 60.00 AS TimeInState,
			   [MODEL],
			   [CREW],
			   ROUND([Feet_Drilled], 0) AS FeetDrilledActual,
			   ROUND([Feet_Drilled_Target], 0) AS FeetDrilledTarget,
			   ROUND([Average_Pen_Rate], 2) AS PenetrationRateActual,
			   PenetrationRateTarget,
			   ROUND([Holes_Drilled], 1) AS HolesDrilledActual,
			   ROUND([Hole_Drilled_Target], 0) AS HolesDrilledTarget,
			   [Depth_Drill_Score] AS [DepthDrillScoreActual],
			   0 AS [DepthDrillScoreTarget],
			   ROUND([UofA], 0) AS AvgUseofAvailActual,
			   ROUND([DRILLUTILIZATION], 2) AS AvgUseofAvailTarget,
			   ROUND([Avail], 0) AS AvailabilityActual,
			   ROUND([DRILLAVAILABILITY], 2) AS AvailabilityTarget,
			   ROUND([AssetEfficiency], 2) AS AssetEfficiencyActual,
			   ROUND([AssetEfficiencyTarget], 2) AS AssetEfficiencyTarget,
			   ROUND([Average_GPS_Quality], 0) AS GPSQualityActual,
			   0 AS [GPSQualityTarget],
			   ROUND([Avg_Time_Between_Holes], 2) AS AvgTimeBnHolesActual,
			   0 AS AvgTimeBnHolesTarget,
			   ROUND([Average_First_Last_Drill], 2) AS AvgFirstLastDrillActual,
			   0 AS AvgFirstLastDrillTarget,
			   [Average_First_Drill] AS [AvgFirstDrillActual],
			   null AS [AvgFirstDrillTarget],
			   [Average_Last_Drill] AS [AvgLastDrillActual],
			   null AS [AvgLastDrillTarget],
			   ROUND([Average_HoleTime], 2) AS AvgDrillingTimeActual,
			   0 AS AvgDrillingTimeTarget,
			   ROUND([XY_Drill_Score], 2) AS XyDrillScoreActual,
			   0 AS XyDrillScoreTarget,
			   ROUND([Over_Drill], 2) AS OverDrilledActual,
			   0 AS OverDrilledTarget,
			   ROUND([Under_Drill], 2) AS UnderDrilledActual,
			   0 AS UnderDrilledTarget,
			   [OVERALLSCORE] AS [PerformanceMatrixActual],
			   0 AS [PerformanceMatrixTarget]
		FROM [BAG].[CONOPS_BAG_DRILL_DETAIL_V]
		WHERE shiftflag = @SHIFT;
		--AND siteflag = @SITE
		--AND ([DRILL_ID] IN (SELECT TRIM(value) FROM STRING_SPLIT(@EQMT, ',')) OR ISNULL(@EQMT, '') = '');

		SELECT [DRILL_ID],
			   Hr,
			   ROUND(ISNULL([Feet_Drilled], 0), 0) AS FeetDrilledActual,
			   ROUND(ISNULL([Average_Pen_Rate], 0), 2) AS PenetrationRateActual,
			   ROUND(ISNULL([Holes_Drilled], 0), 1) AS HolesDrilledActual,
			   ROUND(ISNULL([Depth_Drill_Score], 0), 2) AS DepthDrillScoreActual,
			   ROUND(ISNULL([UofA], 0), 2) AS AvgUseofAvailActual,
			   ROUND(ISNULL([Avail], 0), 2) AS AvgAvailActual,
			   ROUND(ISNULL([AE], 0), 2) AS AvgAssetEfficiencyActual,
			   ROUND(ISNULL([Average_GPS_Quality], 0), 0) AS GPSQualityActual,
			   ROUND(ISNULL([Avg_Time_Between_Holes], 0), 2) AS Av