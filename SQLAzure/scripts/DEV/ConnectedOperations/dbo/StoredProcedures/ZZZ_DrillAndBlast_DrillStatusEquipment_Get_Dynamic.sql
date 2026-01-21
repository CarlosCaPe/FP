


/******************************************************************  
* PROCEDURE	: dbo.DrillAndBlast_DrillStatusEquipment_Get
* PURPOSE	: 
* NOTES		: 
* CREATED	: jrodulfa, 13 Feb 2023
* SAMPLE	: 
	1. EXEC dbo.DrillAndBlast_DrillStatusEquipment_Get 'PREV', 'MOR', NULL, NULL
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {13 Feb 2023}		{jrodulfa}		{Initial Created}
* {17 Feb 2023}		{sxavier}		{Rename field.}
* {02 Mar 2023}		{sxavier}		{Rename field score.}
*******************************************************************/ 
CREATE PROCEDURE [dbo].[DrillAndBlast_DrillStatusEquipment_Get] 
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
			eqmt AS EquipmentName,
			startdatetime AS StartDateTime,
			enddatetime AS EndDateTime,
			duration AS TimeInState,
			reasonidx AS Description1,
			reasons AS Description2,
			LOWER([status]) AS [Status],
			LOWER(eqmtcurrstatus) AS CurrentStatus,
			holes AS NrOfHoles,
			score AS OverallScore
		INTO
			#TempTable
		FROM [' + @SCHEMA + '].[CONOPS_' + @SCHEMA + '_DB_EQMT_STATUS_GANTTCHART_V] (NOLOCK)
		WHERE 
			shiftflag = ''' + @SHIFT + '''
			AND siteflag = ''' + @SITE + '''
			AND (eqmt IN (SELECT TRIM(value) FROM STRING_SPLIT(''' + @EQMT + ''', '','')) OR ISNULL(''' + @EQMT + ''', '''') = '''')
			AND (eqmtcurrstatus IN (SELECT TRIM(value) FROM STRING_SPLIT(UPPER(''' + @STATUS + '''), '','')) OR ISNULL(''' + @STATUS + ''', '''') = '''');

		SELECT
			EquipmentName,
			NrOfHoles,
			OverallScore,
			CurrentStatus
		FROM
			#TempTable
		GROUP BY EquipmentName, NrOfHoles, OverallScore, CurrentStatus

		SELECT * FROM #TempTable

		DROP TABLE #TempTable');

SET NOCOUNT OFF
END

