

/******************************************************************  
* PROCEDURE	: dbo.DrillAndBlast_DrillAssetEfficiency_Get
* PURPOSE	: 
* NOTES		: 
* CREATED	: jrodulfa, 14 Feb 2023
* SAMPLE	: 
	1. EXEC dbo.DrillAndBlast_DrillAssetEfficiency_Get 'CURR', 'MOR'
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {14 Feb 2023}		{jrodulfa}		{Initial Created}
* {15 Feb 2023}		{sxavier}		{Rename field, add EfficiencyTarget and add AvailabilityTarget}
*******************************************************************/ 
CREATE PROCEDURE [dbo].[DrillAndBlast_DrillAssetEfficiency_Get_OLD] 
(	
	@SHIFT VARCHAR(4),
	@SITE VARCHAR(4)
)
AS                        
BEGIN          
	
	SET @SITE = CASE @SITE
					WHEN 'SAM' THEN 'SAF'
					WHEN 'CVE' THEN 'CER'
					WHEN 'CHN' THEN 'CHI'
					ELSE @SITE
				END;

	SELECT ROUND(AVG([AE]),0) AS Efficiency,
		   ROUND(AVG([AETarget]), 0) AS EfficiencyTarget,
	       ROUND(AVG([Avail]),0) AS [Availability],
		   ROUND(AVG([AvailTarget]), 0) AS [AvailabilityTarget],
		   ROUND((AVG([AE])/AVG([Avail])) * 100,0) AS UseOfAvailability
	FROM [dbo].[CONOPS_DB_DRILL_ASSET_EFFICIENCY_V] WITH (NOLOCK)
	WHERE shiftflag = @SHIFT AND siteflag = @SITE

	SELECT
		   [Hr] AS [DateTime],
		   [AE] AS Efficiency,
		   [Avail] AS [Availability],
		   [UofA] AS Utilization
	FROM [dbo].[CONOPS_DB_DRILL_ASSET_EFFICIENCY_V] WITH (NOLOCK)
	WHERE shiftflag = @SHIFT AND siteflag = @SITE
	ORDER BY [HOS]

SET NOCOUNT OFF
END

