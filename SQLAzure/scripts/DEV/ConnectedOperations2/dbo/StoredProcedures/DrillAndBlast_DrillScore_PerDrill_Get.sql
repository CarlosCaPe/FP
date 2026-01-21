
/******************************************************************  
* PROCEDURE	: dbo.DrillAndBlast_DrillScore_PerDrill_Get
* PURPOSE	: 
* NOTES		: 
* CREATED	: jrodulfa, 03 Mar 2023
* SAMPLE	: 
	1. EXEC dbo.DrillAndBlast_DrillScore_PerDrill_Get 'CURR', 'BAG', NULL, NULL, NULL
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {03 Mar 2023}		{jrodulfa}		{Initial Created}
* {08 Mar 2023}		{sxavier}		{Rename field}
* {10 May 2023}		{jrodulfa}		{Update the field for First/Last Drill Hole}
* {15 May 2023}		{sxavier}		{Add alias for AvgFirstDrill adn AvgLastDrill}
* {13 Jun 2023}		{jrodulfa}		{Added Number of Holes}
* {05 Sep 2023}		{ggosal1}		{Add Parameter Equipment Type (MODEL)}
* {03 Jan 2024}		{lwasini}		{Added TYR}
* {09 Jan 2024}		{lwasini}		{Added ABR}
* {11 Nov 2025}		{ggosal1}		{Enhance SplitValue}
*******************************************************************/ 
CREATE PROCEDURE [dbo].[DrillAndBlast_DrillScore_PerDrill_Get] 
(	
	@SHIFT VARCHAR(4),
	@SITE VARCHAR(4),
	@STATUS NVARCHAR(MAX),
	@EQMT NVARCHAR(MAX),
	@EQMTTYPE NVARCHAR(MAX)
)
AS                        
BEGIN          

	DECLARE @splitEqmt [dbo].[udTT_SplitValue];
	DECLARE @splitEStat [dbo].[udTT_SplitValue];
	DECLARE @splitEType [dbo].[udTT_SplitValue];

	INSERT INTO @splitEqmt ([Value])
	SELECT TRIM([value]) FROM STRING_SPLIT(@EQMT, ',');
	
	INSERT INTO @splitEStat ([Value])
	SELECT TRIM([value]) FROM STRING_SPLIT(@STATUS, ',');
	
	INSERT INTO @splitEType ([Value])
	SELECT TRIM([value]) FROM STRING_SPLIT(@EQMTTYPE, ',');

BEGIN TRY

	IF @SITE = 'BAG'
	BEGIN
		SELECT  [DRILL_ID] AS DrillId,
				ISNULL(ROUND(AVG([Average_Pen_Rate]), 2), 0) AS PenetrationRate,
				ISNULL(ROUND(AVG([XY_Drill_Score]),2), 0) AS XyDrillScore,
				ISNULL(ROUND(AVG([Total_Depth]), 2), 0) AS DepthDrillScore,
				ISNULL(ROUND(AVG([Over_Drill]), 2), 0) AS OverDrilled,
				ISNULL(ROUND(AVG([Under_Drill]), 2), 0) AS UnderDrilled,
				ISNULL(ROUND(AVG([Avg_Time_Between_Holes]), 2), 0) AS AvgTimeBnHoles,
				ISNULL(ROUND(AVG([Average_GPS_Quality]), 0), 0) AS GpsQuality,
				ISNULL(ROUND(AVG([Average_First_Last_Drill]), 0), 0) AS AvgFirstLastDrill,
				[Average_First_Drill] AS AvgFirstDrill,
				[Average_Last_Drill] AS AvgLastDrill,
				ISNULL(ROUND(AVG([Average_HoleTime]), 0), 0) AS AvgDrillingTime,
				ISNULL(ROUND(AVG([OVERALLSCORE]), 2), 0) AS OverAllScore,
				ISNULL(ROUND(AVG([Holes_Drilled]), 2), 0) AS NrOfHoles
		FROM [BAG].[CONOPS_BAG_DRILL_DETAIL_V] WITH (NOLOCK)
		WHERE shiftflag = @SHIFT AND siteflag = @SITE
			AND ([DRILL_ID] IN (SELECT [Value] FROM @splitEqmt) OR @EQMT IS NULL)
			AND (eqmtcurrstatus IN (SELECT [Value] FROM @splitEStat) OR @STATUS IS NULL)
			AND (MODEL IN (SELECT [Value] FROM @splitEType) OR @EQMTTYPE IS NULL)
			AND [DRILL_ID] <> 'AC08'
		GROUP BY [DRILL_ID], [Average_First_Drill], [Average_Last_Drill]
		ORDER BY [DRILL_ID]
	END

	ELSE IF @SITE = 'CVE'
	BEGIN
		  SELECT [DRILL_ID] AS DrillId,
				 ISNULL(ROUND(AVG([Average_Pen_Rate]), 2), 0) AS PenetrationRate,
			 	 ISNULL(ROUND(AVG([XY_Drill_Score]),2), 0) AS XyDrillScore,
				 ISNULL(ROUND(AVG([Total_Depth]), 2), 0) AS DepthDrillScore,
				 ISNULL(ROUND(AVG([Over_Drill]), 2), 0) AS OverDrilled,
				 ISNULL(ROUND(AVG([Under_Drill]), 2), 0) AS UnderDrilled,
				 ISNULL(ROUND(AVG([Avg_Time_Between_Holes]), 2), 0) AS AvgTimeBnHoles,
				 ISNULL(ROUND(AVG([Average_GPS_Quality]), 0), 0) AS GpsQuality,
				 ISNULL(ROUND(AVG([Average_First_Last_Drill]), 0), 0) AS AvgFirstLastDrill,
				 [Average_First_Drill] AS AvgFirstDrill,
				 [Average_Last_Drill] AS AvgLastDrill,
				 ISNULL(ROUND(AVG([Average_HoleTime]), 0), 0) AS AvgDrillingTime,
				 ISNULL(ROUND(AVG([OVERALLSCORE]), 2), 0) AS OverAllScore,
				 ISNULL(ROUND(AVG([Holes_Drilled]), 2), 0) AS NrOfHoles
		  FROM [CER].[CONOPS_CER_DRILL_DETAIL_V] WITH (NOLOCK)
		  WHERE shiftflag = @SHIFT
				AND ([D