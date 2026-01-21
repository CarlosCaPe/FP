


/******************************************************************  
* PROCEDURE	: dbo.DrillAndBlast_DrillScore_PerHour_Get
* PURPOSE	: 
* NOTES		: 
* CREATED	: jrodulfa, 06 Mar 2023
* SAMPLE	: 
	1. EXEC dbo.DrillAndBlast_DrillScore_PerHour_Get 'CURR', 'CVE', NULL, NULL
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {06 Mar 2023}		{jrodulfa}		{Initial Created}}
* {10 Mar 2023}		{sxavier}		{Rename field}
*******************************************************************/ 
CREATE PROCEDURE [dbo].[DrillAndBlast_DrillScore_PerHour_Get] 
(	
	@SHIFT VARCHAR(4),
	@SITE VARCHAR(4),
	@STATUS NVARCHAR(MAX),
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

	EXEC('SELECT Hr AS DateTime,
				 ISNULL(ROUND(AVG([Average_Pen_Rate]), 2), 0) AS PenetrationRate,
			 	 ISNULL(ROUND(AVG([XY_Drill_Score]),2), 0) AS XyDrillScore,
				 ISNULL(ROUND(AVG([Total_Depth]), 2), 0) AS DepthDrillScore,
				 ISNULL(ROUND(AVG([Over_Drill]), 2), 0) AS OverDrilled,
				 ISNULL(ROUND(AVG([Under_Drill]), 2), 0) AS UnderDrilled,
				 ISNULL(ROUND(AVG([Avg_Time_Between_Holes]), 2), 0) AS AvgTimeBnHoles,
				 ISNULL(ROUND(AVG([Average_GPS_Quality]), 0), 0) AS GpsQuality,
				 ISNULL(ROUND(AVG([Average_First_Last_Drill]), 0), 0) AS AvgFirstLastDrill,
				 ISNULL(ROUND(AVG([Average_HoleTime]), 0), 0) AS AvgDrillingTime
		  FROM [' + @SCHEMA + '].[CONOPS_' + @SCHEMA + '_DRILL_DETAIL_PER_HOUR_V] WITH (NOLOCK)
		  WHERE shiftflag = ''' + @SHIFT + ''' AND siteflag = ''' + @SITE + '''
				AND ([DRILL_ID] IN (SELECT TRIM(value) FROM STRING_SPLIT(''' + @EQMT + ''', '','')) OR ISNULL(''' + @EQMT + ''', '''') = '''')
				AND (eqmtcurrstatus IN (SELECT TRIM(value) FROM STRING_SPLIT(UPPER(''' + @STATUS + '''), '','')) OR ISNULL(''' + @STATUS + ''', '''') = '''')
		  GROUP BY Hr
		  ORDER BY Hr');

SET NOCOUNT OFF
END

