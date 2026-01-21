
/******************************************************************  
* PROCEDURE	: dbo.Operator_DrillDetail_Get
* PURPOSE	: 
* NOTES		: 
* CREATED	: jrodulfa, 19 Apr 2023
* SAMPLE	: 
	1. EXEC dbo.Operator_DrillDetail_Get 'PREV', 'BAG', '0060060390'
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {19 Apr 2023}		{jrodulfa}		{Initial Created}  
*******************************************************************/ 
CREATE PROCEDURE [dbo].[Operator_DrillDetail_Get] 
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

	IF @SITE = 'BAG'
	BEGIN
		SELECT [shiftflag]
			  ,[siteflag]
			  ,[OPERATORID]
			  ,[OperatorName]
			  ,[OperatorImageURL] as ImageUrl
			  ,[DRILL_ID]
			  ,[CREW]
			  ,[PATTERN_NO] AS [Location]
			  ,ROUND([Feet_Drilled], 0) AS FeetDrilledActual
			  ,ROUND([Feet_Drilled_Target], 0) AS FeetDrilledTarget
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
			  ,ROUND([Average_HoleTime], 2) AS AvgDrillingTimeActual
			  ,0 AS AvgDrillingTimeTarget
			  ,ROUND([XY_Drill_Score], 2) AS XyDrillScoreActual
			  ,0 AS XyDrillScoreTarget
			  ,ROUND([Over_Drill], 2) AS OverDrilledActual
			  ,0 AS OverDrilledTarget
			  ,ROUND([Under_Drill], 2) AS UnderDrilledActual
			  ,0 AS UnderDrilledTarget
			  ,[OVERALLSCORE] AS [PerformanceMatrixActual]
			  ,0 AS [PerformanceMatrixTarget]
		FROM [bag].[CONOPS_BAG_DRILL_DETAIL_V]
		WHERE shiftflag = @SHIFT
			  AND siteflag =  @SITE
			  AND OPERATORID = @OPERID;

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
			   ROUND(ISNULL([Under_Drill], 0), 2) AS UnderDrilledActual,
			   ROUND(ISNULL([OVERALLSCORE], 0), 2) AS [PerformanceMatrixActual]
		FROM [BAG].[CONOPS_BAG_DRILL_DETAIL_PER_HOUR_V]
		WHERE shiftflag = @SHIFT
			  AND siteflag =  @SITE
			  AND OPERATORID = @OPERID
		ORDER BY HOS;
	END

	ELSE IF @SITE = 'CER'
	BEGIN
		SELECT [shiftflag]
			  ,[siteflag]
			  ,[OPERATORID]
			  ,[OperatorName]
			  ,[OperatorImageURL] as ImageUrl
			  ,[DRILL_ID]
			  ,[CREW]
			  ,[PATTERN_NO] AS [Location]
			  ,ROUND([Feet_Drilled], 0) AS FeetDrilledActual
			  ,ROUND([Feet_Drilled_Target], 0) AS FeetDrilledTarget
			  ,ROUND([Average_Pen_Rate], 2) AS PenetrationRateActual
			  ,PenetrationRateTarget
			  ,ROUND([Holes_Drilled], 1) AS HolesDrilledActual
			  ,ROUND([Hole_Drilled_Target], 0) AS HolesDrilled