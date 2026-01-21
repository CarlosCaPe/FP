


/******************************************************************  
* PROCEDURE	: dbo.DrillAndBlast_DrillScore_PerDrill_Get
* PURPOSE	: 
* NOTES		: 
* CREATED	: jrodulfa, 03 Mar 2023
* SAMPLE	: 
	1. EXEC dbo.DrillAndBlast_DrillScore_PerDrill_Get 'CURR', 'MOR', NULL, NULL
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {03 Mar 2023}		{jrodulfa}		{Initial Created}}
* {08 Mar 2023}		{sxavier}		{Rename field}
*******************************************************************/ 
CREATE PROCEDURE [dbo].[DrillAndBlast_DrillScore_PerDrill_Get_OLD] 
(	
	@SHIFT VARCHAR(4),
	@SITE VARCHAR(4),
	@STATUS NVARCHAR(MAX),
	@EQMT NVARCHAR(MAX)
)
AS                        
BEGIN          
	
	SET @SITE = CASE @SITE
					WHEN 'SAM' THEN 'SAF'
					WHEN 'CVE' THEN 'CER'
					WHEN 'CHN' THEN 'CHI'
					ELSE @SITE
				END;

	SELECT [DRILL_ID] AS DrillId,
	       ROUND(AVG(ISNULL([Average_Pen_Rate], 0)), 2) AS PenetrationRate,
		   ROUND(AVG(ISNULL([XY_Drill_Score], 0)),2) AS XyDrillScore,
		   ROUND(AVG(ISNULL([Total_Depth], 0)), 2) AS DepthDrillScore,
	       ROUND(AVG(ISNULL([Over_Drill], 0)), 2) AS OverDrilled,
		   ROUND(AVG(ISNULL([Under_Drill], 0)), 2) AS UnderDrilled,
		   ROUND(AVG(ISNULL([Avg_Time_Between_Holes], 0)), 2) AS AvgTimeBnHoles,
		   ROUND(AVG(ISNULL([Average_GPS_Quality], 0)), 0) AS GpsQuality,
		   ROUND(AVG(ISNULL([Average_First_Last_Drill], 0)), 0) AS AvgFirstLastDrill,
		   ROUND(AVG(ISNULL([Average_HoleTime], 0)), 0) AS AvgDrillingTime
	FROM [dbo].[CONOPS_DRILL_DETAIL_V] WITH (NOLOCK)
	WHERE shiftflag = @SHIFT AND siteflag = @SITE
		  AND ([DRILL_ID] IN (SELECT TRIM(value) FROM STRING_SPLIT(@EQMT, ',')) OR ISNULL(@EQMT, '') = '')
		  AND (eqmtcurrstatus IN (SELECT TRIM(value) FROM STRING_SPLIT(UPPER(@STATUS), ',')) OR ISNULL(@STATUS, '') = '')
	GROUP BY [DRILL_ID]

SET NOCOUNT OFF
END

