







/******************************************************************  
* PROCEDURE	: dbo.DrillAndBlast_DrillAssetEfficiency_Get
* PURPOSE	: 
* NOTES		: 
* CREATED	: jrodulfa, 14 Feb 2023
* SAMPLE	: 
	1. EXEC dbo.DrillAndBlast_DrillAssetEfficiency_Get 'PREV', 'ABR', NULL, NULL, NULL
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {14 Feb 2023}		{jrodulfa}		{Initial Created}
* {15 Feb 2023}		{sxavier}		{Rename field, add EfficiencyTarget and add AvailabilityTarget}
* {13 Mar 2023}		{sxavier}		{Rename filed UseOfAvailibility to Utilization}
* {04 Sep 2023}		{ggosal1}		{Add New Parameter : Equipment, Eq Status, and Eq Type}
* {26 Sep 2023}		{ggosal1}		{Add Drill AE Target, UseOfAvailability --> Utilization} 
* {03 Jan 2024}		{lwasini}		{Add TYR}
* {09 Jan 2024}		{lwasini}		{Added ABR}
*******************************************************************/ 
CREATE PROCEDURE [dbo].[DrillAndBlast_DrillAssetEfficiency_Get] 
(	
	@SHIFT VARCHAR(4),
	@SITE VARCHAR(4),
	@STATUS NVARCHAR(MAX),
	@EQMT NVARCHAR(MAX),
	@EQMTTYPE NVARCHAR(MAX)
)
AS                        
BEGIN          

BEGIN TRY

	IF @SITE = 'BAG'
	BEGIN
	
		SELECT ROUND(AVG([AE]),0) AS OverallEfficiency,
			ROUND(AVG([AE]),0) AS Efficiency,
			ROUND(AVG(ISNULL([aet].DrillEfficiencyTarget,0)),0) AS EfficiencyTarget,
			ROUND(AVG([Avail]),0) AS [Availability],
			ROUND(AVG(ISNULL([aet].DrillAvailabilityTarget,0)),0) AS [AvailabilityTarget],
			CASE WHEN AVG([Avail]) = 0
				THEN 0
				ELSE ROUND((AVG([AE])/AVG([Avail])) * 100,0)
			END AS Utilization,
			ROUND(AVG(ISNULL([aet].DrillUtilizationTarget,0)),0) AS UtilizationTarget
		FROM [BAG].[CONOPS_BAG_HOURLY_DRILL_ASSET_EFFICIENCY_V] [ae] WITH (NOLOCK)
		LEFT JOIN [BAG].[CONOPS_BAG_EQMT_ASSET_EFFICIENCY_TARGET_V] [aet] WITH (NOLOCK)
			ON [ae].siteflag = [aet].SITEFLAG
		WHERE shiftflag = @SHIFT
			  AND (Equipment IN (SELECT TRIM(value) FROM STRING_SPLIT(@EQMT, ',')) OR ISNULL(@EQMT, '') = '')
			  AND (eqmtcurrstatus IN (SELECT TRIM(value) FROM STRING_SPLIT(UPPER(@STATUS ), ',')) OR ISNULL(@STATUS, '') = '')
			  AND (eqmttype IN (SELECT TRIM(value) FROM STRING_SPLIT(@EQMTTYPE, ',')) OR ISNULL(@EQMTTYPE, '') = '')
			  AND Equipment <> 'AC08'
	
		SELECT [Hr] AS [DateTime],
			ROUND(AVG([AE]),0) AS Efficiency,
			ROUND(AVG([Avail]),0) AS [Availability],
			CASE WHEN AVG([Avail]) = 0
				THEN 0
				ELSE ROUND((AVG([AE])/AVG([Avail])) * 100,0)
			END AS Utilization
		FROM [BAG].[CONOPS_BAG_HOURLY_DRILL_ASSET_EFFICIENCY_V] WITH (NOLOCK)
		WHERE shiftflag = @SHIFT
			  AND (Equipment IN (SELECT TRIM(value) FROM STRING_SPLIT(@EQMT, ',')) OR ISNULL(@EQMT, '') = '')
			  AND (eqmtcurrstatus IN (SELECT TRIM(value) FROM STRING_SPLIT(UPPER(@STATUS ), ',')) OR ISNULL(@STATUS, '') = '')
			  AND (eqmttype IN (SELECT TRIM(value) FROM STRING_SPLIT(@EQMTTYPE, ',')) OR ISNULL(@EQMTTYPE, '') = '')
			  AND Equipment <> 'AC08'
		GROUP BY [Hr]
		ORDER BY [Hr]
	
	END
	
	ELSE IF @SITE = 'CVE'
	BEGIN
	
		SELECT ROUND(AVG([AE]),0) AS OverallEfficiency,
			ROUND(AVG([AE]),0) AS Efficiency,
			ROUND(AVG(ISNULL([aet].DrillEfficiencyTarget,0)),0) AS EfficiencyTarget,
			ROUND(AVG([Avail]),0) AS [Availability],
			ROUND(AVG(ISNULL([aet].DrillAvailabilityTarget,0)),0) AS [AvailabilityTarget],
			CASE WHEN AVG([Avail]) = 0
				THEN 0
				ELSE ROUND((AVG([AE])/AVG([Avail])) * 100,0)
			END AS Utilization,
			ROUND(AVG(ISNULL([aet].DrillUtilizationTarget,0)),0) AS UtilizationTarget
		FROM [CER].[CONOPS_CER_HOURLY_DRILL_ASSET_EFFICIENCY_V] [ae] WITH (NOLOCK)
		LEFT JOIN [CER].[CONOPS_CER_EQMT_ASSET_EFFICIENCY_TARGET_V] [aet] WITH (NOLOCK)
			ON [ae].siteflag = [aet].SITEFLAG
		WHERE shiftflag = @SHIFT
			  AND (Equipment IN (SELECT TRIM(value) FROM STRING_SPLIT(@EQMT, ',')) OR ISNULL(@EQMT, '') = '')
			  AND (eqmtcurrstatus IN (SELECT TRIM(value) FROM STRING_SPLIT(UPPER(@STATUS ), ',')) O