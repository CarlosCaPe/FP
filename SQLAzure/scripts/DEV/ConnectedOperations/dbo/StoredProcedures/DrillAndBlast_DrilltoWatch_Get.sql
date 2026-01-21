
/******************************************************************  
* PROCEDURE	: dbo.DrillAndBlast_DrilltoWatch_Get
* PURPOSE	: 
* NOTES		: 
* CREATED	: lwasini, 17 Feb 2023
* SAMPLE	: 
	1. EXEC dbo.DrillAndBlast_DrilltoWatch_Get 'CURR', 'MOR', NULL, NULL, NULL
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {17 Feb 2023}		{lwasini}		{Initial Created}  
* {21 Feb 2023}		{sxavier}		{Rename and remove unused field, comment count DrillsToWatch.}  
* {12 May 2023}		{sxavier}		{Update the field for First/Last Drill Hole}
* {05 Sep 2023}		{ggosal1}		{Add Parameter Equipment Type} 
* {29 Nov 2023}		{ggosal1}		{Add OperatorId} 
* {03 Jan 2024}		{lwasini}		{Added TYR} 
* {09 Jan 2024}		{lwasini}		{Added ABR}
* {11 Nov 2025}		{ggosal1}		{Enhance SplitValue}
* {06 Jan 2026}		{ggosal1}		{Add Auto Drill}
*******************************************************************/ 
CREATE PROCEDURE [dbo].[DrillAndBlast_DrilltoWatch_Get] 
(	
	@SHIFT VARCHAR(4),
	@SITE VARCHAR(4),
	@STATUS NVARCHAR(MAX),
	@EQMT NVARCHAR(MAX),
	@EQMTTYPE NVARCHAR(MAX)
)
AS                        
BEGIN          
		
	SET @SITE = CASE @SITE
					WHEN 'SAM' THEN 'SAF'
					WHEN 'CVE' THEN 'CER'
					WHEN 'CHN' THEN 'CHI'
					ELSE @SITE
				END;

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
		SELECT [DRILL_ID] AS [Name],
			   OperatorImageURL AS ImageUrl,
			   OperatorId,
			   OperatorName,
			   reasonidx AS ReasonIdx,
			   reasons AS Reason,
			   OffTarget,
			   [Actual],
			   [Target],
			   [Holes_Drilled] AS HolesDrilled,
			   NULL AS NrOfAutoDrill,
			   [Availability],
			   Utilization,
			   PenetrationRate,
			   TotalDrillDepth,
			   OverDrilled,
			   UnderDrilled,
			   GpsQuality, 
			   AvgTimeToDrill, 
			   AvgFirstLastDrill, 
			   [Average_First_Drill],
			   [Average_Last_Drill],
			   TimeBetweenHoles 
		FROM [BAG].[CONOPS_BAG_DB_DRILL_TO_WATCH_V] WITH (NOLOCK)
		WHERE shiftflag = @SHIFT
			  AND siteflag = @SITE
			  AND ([DRILL_ID] IN (SELECT [Value] FROM @splitEqmt) OR @EQMT IS NULL)
			  AND (eqmtcurrstatus IN (SELECT [Value] FROM @splitEStat) OR @STATUS IS NULL)
			  AND (eqmttype IN (SELECT [Value] FROM @splitEType) OR @EQMTTYPE IS NULL)
	END

	ELSE IF @SITE = 'CER'
	BEGIN
		SELECT [DRILL_ID] AS [Name],
			   OperatorImageURL AS ImageUrl,
			   OperatorId,
			   OperatorName,
			   reasonidx AS ReasonIdx,
			   reasons AS Reason,
			   OffTarget,
			   [Actual],
			   [Target],
			   [Holes_Drilled] AS HolesDrilled,
			   NULL AS NrOfAutoDrill,
			   [Availability],
			   Utilization,
			   PenetrationRate,
			   TotalDrillDepth,
			   OverDrilled,
			   UnderDrilled,
			   GpsQuality, 
			   AvgTimeToDrill, 
			   AvgFirstLastDrill, 
			   [Average_First_Drill],
			   [Average_Last_Drill],
			   TimeBetweenHoles 
		FROM [CER].[CONOPS_CER_DB_DRILL_TO_WATCH_V] WITH (NOLOCK)
		WHERE shiftflag = @SHIFT
			  AND siteflag = @SITE
			  AND ([DRILL_ID] IN (SELECT [Value] FROM @splitEqmt) OR @EQMT IS NULL)
			  AND (eqmtcurrstatus IN (SELECT [Value] FROM @splitEStat) OR @STATUS IS NULL)
			  AND (eqmttype IN (SELECT [Value] FROM @splitEType) OR @EQMTTYPE IS NULL)
	END

	ELSE IF @SITE = 'CHI'
	BEGIN
		SELECT [DRILL_ID] AS [Name],
			   OperatorImageURL AS ImageUrl,
			   OperatorId,
			   OperatorName,
			   reasonidx AS ReasonIdx,
			   reasons AS Reason,
			   OffTarget,
			   [Actual],
			   [Target],
			   [Holes_Drilled] AS HolesDrilled,
			  