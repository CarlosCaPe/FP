
/******************************************************************  
* PROCEDURE	: dbo.DrillAndBlast_DrillScore_Overall_Get
* PURPOSE	: 
* NOTES		: 
* CREATED	: jrodulfa, 20 Feb 2023
* SAMPLE	: 
	1. EXEC dbo.DrillAndBlast_DrillScore_Overall_Get_OLD 'PREV', 'MOR', NULL, NULL
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {20 Feb 2023}		{jrodulfa}		{Initial Created}}
* {8 Mar 2023}		{sxavier}		{Rename field}
*******************************************************************/ 
CREATE PROCEDURE [dbo].[DrillAndBlast_DrillScore_Overall_Get_OLD] 
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

	SELECT ROUND(AVG([Average_Pen_Rate]), 2) AS PenetrationRate,
		   ROUND(AVG([XY_Drill_Score]),2) AS XyDrillScore,
		   ROUND(AVG([Total_Depth]), 2) AS DepthDrillScore,
	       ROUND(AVG([Over_Drill]), 2) AS OverDrilled,
		   ROUND(AVG([Under_Drill]), 2) AS UnderDrilled,
		   ROUND(AVG([Avg_Time_Between_Holes]), 2) AS AvgTimeBnHoles,
		   ROUND(AVG([Average_GPS_Quality]), 0) AS GpsQuality,
		   ROUND(AVG([Average_First_Last_Drill]), 0) AS AvgFirstLastDrill,
		   ROUND(AVG([Average_HoleTime]), 0) AS AvgDrillingTime
	FROM [dbo].[CONOPS_DRILL_DETAIL_V] WITH (NOLOCK)
	WHERE shiftflag = @SHIFT AND siteflag = @SITE
		  AND ([DRILL_ID] IN (SELECT TRIM(value) FROM STRING_SPLIT(@EQMT, ',')) OR ISNULL(@EQMT, '') = '')
		  AND (eqmtcurrstatus IN (SELECT TRIM(value) FROM STRING_SPLIT(UPPER(@STATUS), ',')) OR ISNULL(@STATUS, '') = '')

SET NOCOUNT OFF
END

