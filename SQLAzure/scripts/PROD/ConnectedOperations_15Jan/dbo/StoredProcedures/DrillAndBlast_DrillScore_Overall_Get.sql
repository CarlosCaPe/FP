

/******************************************************************  
* PROCEDURE	: dbo.DrillAndBlast_DrillScore_Overall_Get
* PURPOSE	: 
* NOTES		: 
* CREATED	: jrodulfa, 20 Feb 2023
* SAMPLE	: 
	1. EXEC dbo.DrillAndBlast_DrillScore_Overall_Get 'PREV', 'SAM', NULL, NULL, NULL
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {20 Feb 2023}		{jrodulfa}		{Initial Created}
* {8 Mar 2023}		{sxavier}		{Rename field}
* {10 May 2023}		{jrodulfa}		{Update the field for First/Last Drill Hole}
* {13 Jun 2023}		{jrodulfa}		{Added Number of Holes}
* {10 Aug 2023}		{ggosal1}		{Fix Number of Holes Value}
* {05 Sep 2023}		{ggosal1}		{Add Parameter Equipment Type}
* {03 Jan 2024}		{lwasini}		{Added TYR}
* {09 Jan 2024}		{lwasini}		{Added ABR}
* {11 Nov 2025}		{ggosal1}		{Enhance SplitValue}
*******************************************************************/ 
CREATE PROCEDURE [dbo].[DrillAndBlast_DrillScore_Overall_Get] 
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
		WITH DrillTime AS (
				SELECT shiftflag,
					   [DRILL_ID],
					   [START_HOLE_TS] AS StartDateTime,
					   [END_HOLE_TS] AS EndDateTime,
					   LEAD([START_HOLE_TS]) OVER ( PARTITION BY shiftflag, siteflag, [DRILL_ID] ORDER BY [START_HOLE_TS] ASC ) AS [NextStartDateTime],
					   ROW_NUMBER() OVER ( PARTITION BY shiftflag, siteflag, [DRILL_ID] ORDER BY [START_HOLE_TS] ASC ) AS [FirstHoleIndex],
					   ROW_NUMBER() OVER ( PARTITION BY shiftflag, siteflag, [DRILL_ID] ORDER BY [START_HOLE_TS] DESC ) AS [LastHoleIndex]
				FROM [bag].[CONOPS_BAG_DB_DRILL_SCORE_CARD_V] WITH (NOLOCK)
				WHERE shiftflag = @SHIFT
					  AND ([DRILL_ID] IN (SELECT [Value] FROM @splitEqmt) OR @EQMT IS NULL)
					  AND (eqmtcurrstatus IN (SELECT [Value] FROM @splitEStat) OR @STATUS IS NULL)
					  AND (eqmttype IN (SELECT [Value] FROM @splitEType) OR @EQMTTYPE IS NULL)
			),

			FirstDrillHole AS (
				SELECT shiftflag,
					   ISNULL(CAST(AVG(CAST(dt.StartDateTime AS FLOAT)) AS DATETIME), NULL) AS [AverageFirstHoleStartDateTime]
				FROM DrillTime dt
				WHERE dt.[FirstHoleIndex] = 1
				GROUP BY shiftflag
			),

			LastDrillHole AS (
				SELECT shiftflag,
					   ISNULL(CAST(AVG(CAST(dt.StartDateTime AS FLOAT)) AS DATETIME), NULL) AS [AverageLastHoleStartDateTime]
				FROM DrillTime dt
				WHERE dt.[LastHoleIndex] = 1
				GROUP BY shiftflag
			)

		SELECT AVG([PENRATE]) AS [PenetrationRate],
			   CASE WHEN COUNT([ds].[DRILL_HOLE]) = 0 THEN 0
					ELSE (SUM([HORIZ_DIFF_FLAG]) / COUNT([ds].[DRILL_HOLE])) * 100
			   END  AS [XyDrillScore],
			   CASE WHEN COUNT([ds].[DRILL_HOLE]) = 0 THEN 0
					ELSE (SUM([DEPTH_DIFF_FLAG]) / COUNT([ds].[DRILL_HOLE])) * 100
			   END  AS [DepthDrillScore],
			   CASE WHEN COUNT([ds].[DRILL_HOLE]) = 0 THEN 0
					ELSE (SUM([OVER_DRILLED]) / COUNT([ds].[DRILL_HOLE])) * 100
			   END  AS [OverDrilled],
			   CASE WHEN COUNT([ds].[DRILL_HOLE]) = 0 THEN 0
					ELSE (SUM([UNDER_DRILLED]) / COUNT([ds].[DRILL_HOLE])) * 100
			   END  AS [UnderDrilled],
			   AVG(DATEDIFF_BIG(SECOND, [dtbh].EndDateTime, [dtbh].NextStartDateTime)) / 60.00 AS [AvgTimeBnHoles],
			   AVG([GPS_QUALITY]) * 100 AS [GpsQuality],
			   AVG(DATEDIFF(SECOND, ShiftStartDateTime, [fdh].[AverageFirstHoleStartDateTime]) / 60.00) AS [AvgFirstLastDrill],
			   [fdh].[AverageFirstHoleStartDateTime] AS 