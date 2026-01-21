

/******************************************************************  
* PROCEDURE	: dbo.Operator_DrillDetail_HourlyData_Get
* PURPOSE	: 
* NOTES		: 
* CREATED	: jrodulfa, 19 Apr 2023
* SAMPLE	: 
	1. EXEC dbo.Operator_DrillDetail_HourlyData_Get 'PREV', 'ABR', '0000054954'
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {19 Apr 2023}		{jrodulfa}		{Initial Created}  
* {27 Oct 2023}		{ggosal1}		{MVP 8.2, remove FeetDrilled & Availabilit} 
* {22 Jan 2024}		{lwasini}		{Add TYR}  
* {24 Jan 2024}		{lwasini}		{Add ABR}  
*******************************************************************/ 
CREATE PROCEDURE [dbo].[Operator_DrillDetail_HourlyData_Get] 
(	
	@SHIFT VARCHAR(4),
	@SITE VARCHAR(4),
	@OPERID VARCHAR(50)
)
AS                        
BEGIN  

	SET @SITE = CASE @SITE
					WHEN 'SAM' THEN 'SAF'
					WHEN 'CVE' THEN 'CER'
					WHEN 'CHN' THEN 'CHI'
					ELSE @SITE
				END;

BEGIN TRY

	IF @SITE = 'BAG'
	BEGIN
		SELECT TOP 1 [shiftflag]
			  ,[siteflag]
			  ,[OPERATORID]
			  ,ROUND([Average_Pen_Rate], 2) AS PenetrationRateActual
			  ,PenetrationRateTarget
			  ,ROUND([Holes_Drilled], 1) AS HolesDrilledActual
			  ,ROUND([Hole_Drilled_Target], 0) AS HolesDrilledTarget
			  ,ROUND([Total_Depth], 2) AS TotalDrillDepthActual
			  ,0 AS TotalDrillDepthTarget
			  ,ROUND([UofA], 2) AS AvgUseofAvailActual
			  ,ROUND([DRILLUTILIZATION], 2) AS AvgUseofAvailTarget
			  ,ROUND([Average_GPS_Quality], 0) AS GPSQualityActual
			  ,0 AS [GPSQualityTarget]
			  ,ROUND([Avg_Time_Between_Holes], 2) AS AvgTimeBnHolesActual
			  ,0 AS AvgTimeBnHolesTarget
			  ,ROUND([Average_First_Last_Drill], 2) AS AvgFirstLastDrillActual
			  ,0 AS AvgFirstLastDrillTarget
			  ,[Average_First_Drill] AS AvgFirstDrillActual
			  ,NULL AS AvgFirstDrillTarget
			  ,[Average_Last_Drill] AS AvgLastDrillActual
			  ,NULL AS AvgLastDrillTarget
			  ,ROUND([Average_HoleTime], 2) AS AvgDrillingTimeActual
			  ,0 AS AvgDrillingTimeTarget
			  ,ROUND([XY_Drill_Score], 2) AS XyDrillScoreActual
			  ,0 AS XyDrillScoreTarget
			  ,ROUND([Over_Drill], 2) AS OverDrilledActual
			  ,0 AS OverDrilledTarget
			  ,ROUND([Under_Drill], 2) AS UnderDrilledActual
			  ,0 AS UnderDrilledTarget
			  ,[Depth_Drill_Score] AS [DepthDrillScoreActual]
			  ,0 AS [DepthDrillScoreTarget]
			  ,[OVERALLSCORE] AS [PerformanceMatrixActual]
			  ,0 AS [PerformanceMatrixTarget]
		FROM [bag].[CONOPS_BAG_DRILL_DETAIL_V]
		WHERE shiftflag = @SHIFT
			  AND siteflag =  @SITE
			  AND OPERATORID = @OPERID;

		SELECT [shiftflag],
			   [siteflag],
			   [OPERATORID],
			   Hr,
			   ROUND(ISNULL([Feet_Drilled], 0), 0) AS FeetDrilledActual
		FROM [BAG].[CONOPS_BAG_DRILL_DETAIL_PER_HOUR_V]
		WHERE shiftflag = @SHIFT
			  AND siteflag =  @SITE
			  AND OPERATORID = @OPERID
		ORDER BY HOS;
	END

	ELSE IF @SITE = 'CER'
	BEGIN
		SELECT TOP 1 [shiftflag]
			  ,[siteflag]
			  ,[OPERATORID]
			  ,ROUND([Average_Pen_Rate], 2) AS PenetrationRateActual
			  ,PenetrationRateTarget
			  ,ROUND([Holes_Drilled], 1) AS HolesDrilledActual
			  ,ROUND([Hole_Drilled_Target], 0) AS HolesDrilledTarget
			  ,ROUND([Total_Depth], 2) AS TotalDrillDepthActual
			  ,0 AS TotalDrillDepthTarget
			  ,ROUND([UofA], 2) AS AvgUseofAvailActual
			  ,ROUND([DRILLUTILIZATION], 2) AS AvgUseofAvailTarget
			  ,ROUND([Average_GPS_Quality], 0) AS GPSQualityActual
			  ,0 AS [GPSQualityTarget]
			  ,ROUND([Avg_Time_Between_Holes], 2) AS AvgTimeBnHolesActual
			  ,0 AS AvgTimeBnHolesTarget
			  ,ROUND([Average_First_Last_Drill], 2) AS AvgFirstLastDrillActual
			  ,0 AS AvgFirstLastDrillTarget
			  ,[Average_First_Drill] AS AvgFirstDrillActual
			  ,NULL AS AvgFirstDrillTarget
			  ,[Average_Last_Drill] AS AvgLastDrillActual
			  ,NULL AS AvgLastDrillTarget
			  ,ROUND([Average_HoleTime], 2) AS AvgDrillingTimeActual
			  ,0 AS AvgDrillingTimeTarget
			  ,ROUND([XY_