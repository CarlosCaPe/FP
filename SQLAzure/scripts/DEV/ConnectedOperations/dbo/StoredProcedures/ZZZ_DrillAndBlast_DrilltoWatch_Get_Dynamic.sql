
/******************************************************************  
* PROCEDURE	: dbo.DrillAndBlast_DrilltoWatch_Get
* PURPOSE	: 
* NOTES		: 
* CREATED	: lwasini, 17 Feb 2023
* SAMPLE	: 
	1. EXEC dbo.DrillAndBlast_DrilltoWatch_Get 'CURR', 'BAG', NULL, NULL
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {17 Feb 2023}		{lwasini}		{Initial Created}  
* {21 Feb 2023}		{sxavier}		{Rename and remove unused field, comment count DrillsToWatch.}  
*******************************************************************/ 
CREATE PROCEDURE [dbo].[DrillAndBlast_DrilltoWatch_Get] 
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

	EXEC('SELECT
			[DRILL_ID] AS [Name],
			OperatorImageURL AS ImageUrl,
			OperatorName,
			reasonidx AS ReasonIdx,
			reasons AS Reason,
			OffTarget,
			[Actual],
			[Target],
			[Holes_Drilled] AS HolesDrilled,
			[Availability],
			Utilization,
			PenetrationRate,
			TotalDrillDepth,
			OverDrilled,
			UnderDrilled,
			GpsQuality, 
			AvgTimeToDrill, 
			AvgFirstLastDrill, 
			TimeBetweenHoles 
		FROM [' + @SCHEMA + '].[CONOPS_' + @SCHEMA + '_DB_DRILL_TO_WATCH_V] WITH (NOLOCK)
		WHERE shiftflag = ''' + @SHIFT + '''
			  AND siteflag = ''' + @SITE + '''
			  AND ([DRILL_ID] IN (SELECT TRIM(value) FROM STRING_SPLIT(''' + @EQMT + ''', '','')) OR ISNULL(''' + @EQMT + ''', '''') = '''')
			  AND (eqmtcurrstatus IN (SELECT TRIM(value) FROM STRING_SPLIT(UPPER(''' + @STATUS + '''), '','')) OR ISNULL(''' + @STATUS + ''', '''') = '''')');
	
SET NOCOUNT OFF
END

