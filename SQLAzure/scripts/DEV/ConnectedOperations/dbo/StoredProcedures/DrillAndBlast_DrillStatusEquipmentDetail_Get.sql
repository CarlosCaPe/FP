

/******************************************************************  
* PROCEDURE	: dbo.DrillAndBlast_DrillStatusEquipmentDetail_Get
* PURPOSE	: 
* NOTES		: 
* CREATED	: jrodulfa, 23 Feb 2022
* SAMPLE	: 
	1. EXEC dbo.DrillAndBlast_DrillStatusEquipmentDetail_Get 'CURR', 'MOR', NULL, NULL, NULL
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {23 Feb 2023}		{jrodulfa}		{Initial Created} 
* {28 Feb 2023}		{sxavier}		{Rename field.} 
* {12 May 2023}		{jrodulfa}		{Update the field for First/Last Drill Hole}
* {07 Sep 2023}		{ggosal1}		{Add Parameter Equipment Type (MODEL)} 
* {29 Nov 2023}		{ggosal1}		{Add OperatorID}
* {03 Jan 2024}		{lwasini}		{Added TYR}
* {09 Jan 2024}		{lwasini}		{Added ABR}
* {11 Nov 2025}		{ggosal1}		{Enhance SplitValue}
* {06 Jan 2026}		{ggosal1}		{Add Auto Drill}
*******************************************************************/ 
CREATE PROCEDURE [dbo].[DrillAndBlast_DrillStatusEquipmentDetail_Get] 
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
		SELECT  [DRILL_ID] AS [Name],
				OperatorId,
				OperatorName,
				[OperatorImageURL] as ImageUrl,
				reasons AS Reason,
				reasonidx AS ReasonIdx,
				ROUND([Feet_Drilled], 0) AS FeetDrilled,
				ROUND([Holes_Drilled], 2) AS HolesDrilled,
				NULL AS NrOfAutoDrill,
				ROUND([Avail], 2) AS [Availability],
				ROUND([UofA], 2) AS Utilization,
				ROUND([Average_Pen_Rate], 2) AS PenetrationRate,
				ROUND([Total_Depth], 2) AS TotalDrillDepth,
				ROUND([Over_Drill], 2) AS OverDrilled,
				ROUND([Under_Drill], 2) AS UnderDrilled,
				ROUND([Average_GPS_Quality], 0) AS GPSQuality,
				ROUND([Average_HoleTime], 2) AS AvgTimeToDrill,
				ROUND([Avg_Time_Between_Holes], 2) AS TimeBetweenHoles,
				ROUND([Average_First_Last_Drill], 2) AS AvgFirstLastDrill,
				[Average_First_Drill],
				[Average_Last_Drill],
				eqmtcurrstatus,
				MODEL as eqmttype
		FROM [BAG].[CONOPS_BAG_DRILL_DETAIL_V]
		WHERE shiftflag = @SHIFT
			  AND siteflag = @SITE
			  AND ([DRILL_ID] IN (SELECT [Value] FROM @splitEqmt) OR @EQMT IS NULL)
			  AND (eqmtcurrstatus IN (SELECT [Value] FROM @splitEStat) OR @STATUS IS NULL)
			  AND (MODEL IN (SELECT [Value] FROM @splitEType) OR @EQMTTYPE IS NULL)
	END

	ELSE IF @SITE = 'CER'
	BEGIN
		SELECT  [DRILL_ID] AS [Name],
				OperatorId,
				OperatorName,
				[OperatorImageURL] as ImageUrl,
				reasons AS Reason,
				reasonidx AS ReasonIdx,
				ROUND([Feet_Drilled], 0) AS FeetDrilled,
				ROUND([Holes_Drilled], 2) AS HolesDrilled,
				NULL AS NrOfAutoDrill,
				ROUND([Avail], 2) AS [Availability],
				ROUND([UofA], 2) AS Utilization,
				ROUND([Average_Pen_Rate], 2) AS PenetrationRate,
				ROUND([Total_Depth], 2) AS TotalDrillDepth,
				ROUND([Over_Drill], 2) AS OverDrilled,
				ROUND([Under_Drill], 2) AS UnderDrilled,
				ROUND([Average_GPS_Quality], 0) AS GPSQuality,
				ROUND([Average_HoleTime], 2) AS AvgTimeToDrill,
				ROUND([Avg_Time_Between_Holes], 2) AS TimeBetweenHoles,
				ROUND([Average_First_Last_Drill], 2) AS AvgFirstLastDrill,
				[Average_First_Drill],
				[Average_Last_Drill],
				eqmtcurrstatus,
				MODEL as eqmttype
		FROM [CER].[CONOPS_CER_DRILL_DETAIL_V]
		WHERE shiftflag = @SH