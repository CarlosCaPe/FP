


/******************************************************************  
* PROCEDURE	: dbo.DrillAndBlast_DrillAssetEfficiency_Get
* PURPOSE	: 
* NOTES		: 
* CREATED	: jrodulfa, 14 Feb 2023
* SAMPLE	: 
	1. EXEC dbo.DrillAndBlast_DrillAssetEfficiency_Get 'CURR', 'CHN'
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {14 Feb 2023}		{jrodulfa}		{Initial Created}
* {15 Feb 2023}		{sxavier}		{Rename field, add EfficiencyTarget and add AvailabilityTarget}
*******************************************************************/ 
CREATE   PROCEDURE [dbo].[DrillAndBlast_DrillAssetEfficiency_Get_NoDynamicSQL] 
(	
	@SHIFT VARCHAR(4),
	@SITE VARCHAR(4)
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

	IF (@SITE = 'BAG')
	BEGIN
			SELECT ROUND(AVG([AE]),0) AS Efficiency,
					 ROUND(AVG([AETarget]), 0) AS EfficiencyTarget,
					 ROUND(AVG([Avail]),0) AS [Availability],
					 ROUND(AVG([AvailTarget]), 0) AS [AvailabilityTarget],
					 CASE WHEN AVG([Avail]) = 0
						  THEN 0
						  ELSE ROUND((AVG([AE])/AVG([Avail])) * 100,0)
					 END AS UseOfAvailability
			FROM	[BAG].[CONOPS_BAG_HOURLY_DRILL_ASSET_EFFICIENCY_V] WITH (NOLOCK)
			WHERE	shiftflag = @SHIFT AND siteflag = @SITE;

			SELECT [Hr] AS [DateTime],
					 ROUND(AVG([AE]),0) AS Efficiency,
					 ROUND(AVG([Avail]),0) AS [Availability],
					 CASE WHEN AVG([Avail]) = 0
						  THEN 0
						  ELSE ROUND((AVG([AE])/AVG([Avail])) * 100,0)
					 END AS UseOfAvailability
			  FROM [BAG].[CONOPS_BAG_HOURLY_DRILL_ASSET_EFFICIENCY_V] WITH (NOLOCK)
			  WHERE shiftflag = @SHIFT AND siteflag = @SITE
			  GROUP BY [Hr]
			  ORDER BY [Hr]

	END

	IF (@SITE = 'CER')
	BEGIN
			SELECT ROUND(AVG([AE]),0) AS Efficiency,
					 ROUND(AVG([AETarget]), 0) AS EfficiencyTarget,
					 ROUND(AVG([Avail]),0) AS [Availability],
					 ROUND(AVG([AvailTarget]), 0) AS [AvailabilityTarget],
					 CASE WHEN AVG([Avail]) = 0
						  THEN 0
						  ELSE ROUND((AVG([AE])/AVG([Avail])) * 100,0)
					 END AS UseOfAvailability
			FROM	[CER].[CONOPS_CER_HOURLY_DRILL_ASSET_EFFICIENCY_V] WITH (NOLOCK)
			WHERE	shiftflag = @SHIFT AND siteflag = @SITE;

			SELECT [Hr] AS [DateTime],
					 ROUND(AVG([AE]),0) AS Efficiency,
					 ROUND(AVG([Avail]),0) AS [Availability],
					 CASE WHEN AVG([Avail]) = 0
						  THEN 0
						  ELSE ROUND((AVG([AE])/AVG([Avail])) * 100,0)
					 END AS UseOfAvailability
			  FROM [CER].[CONOPS_CER_HOURLY_DRILL_ASSET_EFFICIENCY_V] WITH (NOLOCK)
			  WHERE shiftflag = @SHIFT AND siteflag = @SITE
			  GROUP BY [Hr]
			  ORDER BY [Hr]


	END

	IF (@SITE = 'CLI')
	BEGIN
			SELECT ROUND(AVG([AE]),0) AS Efficiency,
					 ROUND(AVG([AETarget]), 0) AS EfficiencyTarget,
					 ROUND(AVG([Avail]),0) AS [Availability],
					 ROUND(AVG([AvailTarget]), 0) AS [AvailabilityTarget],
					 CASE WHEN AVG([Avail]) = 0
						  THEN 0
						  ELSE ROUND((AVG([AE])/AVG([Avail])) * 100,0)
					 END AS UseOfAvailability
			FROM	[CLI].[CONOPS_CLI_HOURLY_DRILL_ASSET_EFFICIENCY_V] WITH (NOLOCK)
			WHERE	shiftflag = @SHIFT AND siteflag = @SITE;

			SELECT [Hr] AS [DateTime],
					 ROUND(AVG([AE]),0) AS Efficiency,
					 ROUND(AVG([Avail]),0) AS [Availability],
					 CASE WHEN AVG([Avail]) = 0
						  THEN 0
						  ELSE ROUND((AVG([AE])/AVG([Avail])) * 100,0)
					 END AS UseOfAvailability
			FROM [CLI].[CONOPS_CLI_HOURLY_DRILL_ASSET_EFFICIENCY_V] WITH (NOLOCK)
			WHERE shiftflag = @SHIFT AND siteflag = @SITE
			GROUP BY [Hr]
			ORDER BY [Hr]


	END

	IF (@SITE = 'SAF')
	BEGIN
			SELECT ROUND(AVG([AE]),0) AS Efficiency,
					 ROUND(AVG([AETarget]), 0) AS EfficiencyTarget,
					 ROUND(AVG([Avail]),0) AS 