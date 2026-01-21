

/******************************************************************  
* PROCEDURE	: dbo.DrillAndBlast_DrillScore_Overall_Get
* PURPOSE	: 
* NOTES		: 
* CREATED	: jrodulfa, 20 Feb 2023
* SAMPLE	: 
	1. EXEC dbo.DrillAndBlast_DrillScore_Overall_Get 'PREV', 'SAM', NULL, NULL
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {20 Feb 2023}		{jrodulfa}		{Initial Created}}
* {8 Mar 2023}		{sxavier}		{Rename field}
*******************************************************************/ 
CREATE PROCEDURE [dbo].[DrillAndBlast_DrillScore_Overall_Get] 
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

	EXEC('WITH DrillTime AS (
				SELECT shiftflag,
					   [START_HOLE_TS] AS StartDateTime,
					   [END_HOLE_TS] AS EndDateTime,
					   LEAD([START_HOLE_TS]) OVER ( PARTITION BY [DRILL_ID] ORDER BY [START_HOLE_TS] ASC ) AS [NextStartDateTime] ,
					   ROW_NUMBER() OVER ( PARTITION BY [DRILL_ID] ORDER BY [START_HOLE_TS] ASC ) AS [DrillIndex]
				FROM [' + @SCHEMA + '].[CONOPS_' + @SCHEMA + '_DB_DRILL_SCORE_CARD_V] WITH (NOLOCK)
				WHERE shiftflag = ''' + @SHIFT + '''
					  AND ([DRILL_ID] IN (SELECT TRIM(value) FROM STRING_SPLIT(''' + @EQMT + ''', '','')) OR ISNULL(''' + @EQMT + ''', '''') = '''')
					  AND (eqmtcurrstatus IN (SELECT TRIM(value) FROM STRING_SPLIT(UPPER(''' + @STATUS + '''), '','')) OR ISNULL(''' + @STATUS + ''', '''') = '''')
			),

			FirstDrillHole AS (
				SELECT shiftflag,
					   CAST(AVG(CAST(dt.StartDateTime AS FLOAT)) AS DATETIME) AS [AverageStartDateTime]
				FROM DrillTime dt
				WHERE dt.DrillIndex = 1
				GROUP BY shiftflag
			)

		SELECT AVG([PENRATE]) AS [PenetrationRate],
			   CASE WHEN COUNT([ds].[DRILL_ID]) = 0 THEN 0
					ELSE (SUM([HORIZ_DIFF_FLAG]) / COUNT([ds].[DRILL_ID])) * 100
			   END  AS [XyDrillScore],
			   CASE WHEN COUNT([ds].[DRILL_ID]) = 0 THEN 0
					ELSE (SUM([DEPTH_DIFF_FLAG]) / COUNT([ds].[DRILL_ID])) * 100
			   END  AS [DepthDrillScore],
			   CASE WHEN COUNT([ds].[DRILL_ID]) = 0 THEN 0
					ELSE (SUM([OVER_DRILLED]) / COUNT([ds].[DRILL_ID])) * 100
			   END  AS [OverDrilled],
			   CASE WHEN COUNT([ds].[DRILL_ID]) = 0 THEN 0
					ELSE (SUM([UNDER_DRILLED]) / COUNT([ds].[DRILL_ID])) * 100
			   END  AS [UnderDrilled],
			   AVG(DATEDIFF_BIG(SECOND, [dtbh].EndDateTime, [dtbh].NextStartDateTime)) / 60.00 AS [AvgTimeBnHoles],
			   AVG([GPS_QUALITY]) * 100 AS [GpsQuality],
			   AVG(DATEDIFF(SECOND, ShiftStartDateTime, [fdh].[AverageStartDateTime]) / 60.00) AS [AvgFirstLastDrill],
			   AVG(HOLETIME) AS [AvgDrillingTime],
			   AVG(OVERALLSCORE) AS OverAllScore
		FROM [' + @SCHEMA + '].[CONOPS_' + @SCHEMA + '_DB_DRILL_SCORE_CARD_V] [ds] WITH (NOLOCK)
		LEFT JOIN DrillTime [dtbh]
		ON [dtbh].shiftflag = [ds].shiftflag AND [dtbh].NextStartDateTime IS NOT NULL
		LEFT JOIN FirstDrillHole [fdh]
		ON [fdh].shiftflag = [ds].shiftflag
		WHERE [ds].shiftflag = ''' + @SHIFT + '''
			  AND ([ds].[DRILL_ID] IN (SELECT TRIM(value) FROM STRING_SPLIT(''' + @EQMT + ''', '','')) OR ISNULL(''' + @EQMT + ''', '''') = '''')
			  AND (eqmtcurrstatus IN (SELECT TRIM(value) FROM STRING_SPLIT(UPPER(''' + @STATUS + '''), '','')) OR ISNULL(''' + @STATUS + ''', '''') = '''')
	');
	
SET NOCOUNT OFF
END

