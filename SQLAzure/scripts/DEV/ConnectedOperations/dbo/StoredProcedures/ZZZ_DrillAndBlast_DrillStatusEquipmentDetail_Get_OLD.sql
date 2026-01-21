
/******************************************************************  
* PROCEDURE	: dbo.DrillAndBlast_DrillStatusEquipmentDetail_Get
* PURPOSE	: 
* NOTES		: 
* CREATED	: jrodulfa, 23 Feb 2022
* SAMPLE	: 
	1. EXEC dbo.DrillAndBlast_DrillStatusEquipmentDetail_Get 'PREV', 'CVE', NULL, NULL
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {23 Feb 2023}		{jrodulfa}		{Initial Created} 
* {28 Feb 2023}		{sxavier}		{Rename field.} 
*******************************************************************/ 
CREATE PROCEDURE [dbo].[DrillAndBlast_DrillStatusEquipmentDetail_Get_OLD] 
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

	SELECT 
		[DRILL_ID] AS [Name],
		OperatorName,
		[OperatorImageURL] as ImageUrl,
		reasons AS Reason,
		reasonidx AS ReasonIdx,
		ROUND([Feet_Drilled], 0) AS FeetDrilled,
		ROUND([Holes_Drilled], 2) AS HolesDrilled,
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
		eqmtcurrstatus
	FROM [mor].[CONOPS_MOR_DRILL_DETAIL_V]
	WHERE shiftflag = @SHIFT
	AND siteflag = @SITE
	AND ([DRILL_ID] IN (SELECT TRIM(value) FROM STRING_SPLIT(@EQMT, ',')) OR ISNULL(@EQMT, '') = '')
	AND (eqmtcurrstatus IN (SELECT TRIM(value) FROM STRING_SPLIT(UPPER(@STATUS), ',')) OR ISNULL(@STATUS, '') = '')
		
SET NOCOUNT OFF
END

