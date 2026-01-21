

/******************************************************************  
* PROCEDURE	: dbo.DrillAndBlast_DrillStatusEquipment_Get
* PURPOSE	: 
* NOTES		: 
* CREATED	: jrodulfa, 13 Feb 2023
* SAMPLE	: 
	1. EXEC dbo.DrillAndBlast_DrillStatusEquipment_Get 'CURR', 'MOR', NULL, NULL, NULL
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {13 Feb 2023}		{jrodulfa}		{Initial Created}
* {17 Feb 2023}		{sxavier}		{Rename field.}
* {02 Mar 2023}		{sxavier}		{Rename field score.}
* {31 Aug 2023}		{lwasini}		{Add Equipment Type}
* {07 Sep 2023}		{ggosal1}		{Add Parameter Equipment Type} 
* {27 Sep 2023}		{lwasini}		{Add Elevation Column} 
* {10 Nov 2023}		{lwasini}		{Add OperatorName}
* {03 Jan 2024}		{lwasini}		{Added TYR}
* {09 Jan 2024}		{lwasini}		{Added ABR}
* {17 May 2024}		{ggosal1}		{Add UseOfAvailability}
* {11 Nov 2025}		{ggosal1}		{Enhance SplitValue}
* {02 Dec 2025}		{ggosal1}		{Add AutoDrill}
*******************************************************************/ 
CREATE PROCEDURE [dbo].[DrillAndBlast_DrillStatusEquipment_Get] 
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

		SELECT eqmt AS EquipmentName,
			   eqmttype AS EquipmentType,
			   startdatetime AS StartDateTime,
			   enddatetime AS EndDateTime,
			   a.duration AS TimeInState,
			   a.reasonidx AS Description1,
			   a.reasons AS Description2,
			   LOWER([status]) AS [Status],
			   LOWER(a.eqmtcurrstatus) AS CurrentStatus,
			   holes AS NrOfHoles,
			   NULL AS NrOfAutoDrill,
			   score AS OverallScore,
			   Elevation,
			   OperatorName,
			   ROUND(UofA,2) AS UseOfAvailability
		INTO   #TempTableBAG
		FROM   [BAG].[CONOPS_BAG_DB_EQMT_STATUS_GANTTCHART_V] a (NOLOCK)
		LEFT JOIN [BAG].[CONOPS_BAG_DRILL_DETAIL_V] b
		ON a.shiftflag= b.shiftflag AND a.eqmt = b.DRILL_ID
		WHERE  a.shiftflag = @SHIFT
			   AND (eqmt IN (SELECT [Value] FROM @splitEqmt) OR @EQMT IS NULL)
			   AND (a.eqmtcurrstatus IN (SELECT [Value] FROM @splitEStat) OR @STATUS IS NULL)
			   AND (eqmttype IN (SELECT [Value] FROM @splitEType) OR @EQMTTYPE IS NULL)
	  
		SELECT EquipmentName,
			   EquipmentType,
			   Elevation,
			   NrOfHoles,
			   NrOfAutoDrill,
			   OverallScore,
			   CurrentStatus,
			   UseOfAvailability
		FROM   #TempTableBAG
		GROUP BY EquipmentName, EquipmentType, NrOfHoles, NrOfAutoDrill, OverallScore, CurrentStatus, Elevation, UseOfAvailability
 
		SELECT * FROM #TempTableBAG
 
		DROP TABLE #TempTableBAG;
 
		SELECT SHIFTSTARTDATETIME,
			   SHIFTENDDATETIME
		FROM [BAG].[CONOPS_BAG_SHIFT_INFO_V] WITH (NOLOCK)
		WHERE SHIFTFLAG = @SHIFT;

	END

	ELSE IF @SITE = 'CVE'
	BEGIN

		SELECT eqmt AS EquipmentName,
			   eqmttype AS EquipmentType,
			   startdatetime AS StartDateTime,
			   enddatetime AS EndDateTime,
			   a.duration AS TimeInState,
			   a.reasonidx AS Description1,
			   a.reasons AS Description2,
			   LOWER([status]) AS [Status],
			   LOWER(a.eqmtcurrstatus) AS CurrentStatus,
			   holes AS NrOfHoles,
			   NULL AS NrOfAutoDrill,
			   score AS OverallScore,
			   Elevation,
			   OperatorName,
			   ROUND(UofA,2) AS UseOfAvailability
		INTO   #TempTableCER
		FROM   [CER].[CONOPS_CER_DB_EQMT_STATUS_GANTTCHART_V] a (NOLOCK)
		LEFT JOIN [CER].[CONOPS_CER_DRILL_DETAIL_V] b
		ON a.shiftflag= b.shiftflag AND a.eqmt = b.DRILL_