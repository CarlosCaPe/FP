
/******************************************************************  
* PROCEDURE	: dbo.Equipment_Drill_Get
* PURPOSE	: 
* NOTES		: 
* CREATED	: jrodulfa, 24 Feb 2023
* SAMPLE	: 
	1. EXEC dbo.Equipment_Drill_Get 'PREV', 'MOR', NULL
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {24 Feb 2023}		{jrodulfa}		{Initial Created}}
*******************************************************************/ 
CREATE PROCEDURE [dbo].[Equipment_Drill_Get] 
(	
	@SHIFT VARCHAR(4),
	@SITE VARCHAR(4),
	@STATUS NVARCHAR(MAX)
	--@EQMT NVARCHAR(MAX)
)
AS                        
BEGIN          
	
	SET @SITE = CASE @SITE
					WHEN 'SAM' THEN 'SAF'
					WHEN 'CVE' THEN 'CER'
					WHEN 'CHN' THEN 'CHI'
					ELSE @SITE
				END;

	SELECT [DRILL_ID] AS [Name],
		   [Location],
		   [OperatorName],
		   [OperatorImageURL] as ImageUrl,
		   ROUND([Holes_Drilled], 1) AS HolesDrilledActual,
		   ROUND([Hole_Drilled_Target], 0) AS HolesDrilledTarget,
		   [PerformanceMatrixActual],
		   [PerformanceMatrixTarget],
		   ROUND([Average_Pen_Rate], 2) AS PenetrationRateActual,
		   PenetrationRateTarget,
		   ROUND([Total_Depth], 2) AS TotalDrillDepthActual,
		   [DrillDepthTarget] AS TotalDrillDepthTarget,
		   ROUND([Average_GPS_Quality], 0) AS GPSQualityActual,
		   [GPSQualityTarget],
		   ROUND([UofA], 2) AS AvgUseofAvailActual,
		   ROUND([DRILLUTILIZATION], 2) AS AvgUseofAvailTarget,
		   ROUND([Feet_Drilled], 0) AS FeetDrilledActual,
		   ROUND([Feet_Drilled_Target], 0) AS FeetDrilledTarget,
		   reasons AS Reason,
		   reasonidx AS ReasonIdx,
		   [Duration] AS TimeInState,
		   [MODEL],
		   eqmtcurrstatus
	FROM [dbo].[CONOPS_EQMT_DRILL_V]
	WHERE shiftflag = @SHIFT
	AND siteflag = @SITE
	AND (eqmtcurrstatus IN (SELECT TRIM(value) FROM STRING_SPLIT(UPPER(@STATUS), ',')) OR ISNULL(@STATUS, '') = '')

SET NOCOUNT OFF
END

