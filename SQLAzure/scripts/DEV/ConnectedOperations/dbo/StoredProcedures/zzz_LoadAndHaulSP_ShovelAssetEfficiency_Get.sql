

/******************************************************************  
* PROCEDURE	: dbo.LoadAndHaulSP_ShovelAssetEfficiency_Get
* PURPOSE	: 
* NOTES		: 
* CREATED	: jrodulfa, 22 Dec 2022
* SAMPLE	: 
	1. EXEC dbo.LoadAndHaulSP_ShovelAssetEfficiency_Get 'CURR', 'CVE'
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {22 Dec 2022}		{jrodulfa}		{Initial Created} 
* {23 Dec 2022}		{sxavier}		{Rename field} 
* {18 Sep 2023}		{lwasini}		{Add Paramter EQMT,EQMTTYPE,STATUS}
*******************************************************************/ 
CREATE PROCEDURE [dbo].[zzz_LoadAndHaulSP_ShovelAssetEfficiency_Get] 
(	
	@SHIFT VARCHAR(4),
	@SITE VARCHAR(4)
)
AS                        
BEGIN          
	
	IF @SITE = 'BAG'
	BEGIN

		SELECT
			ROUND(AVG([AE]),0) AS Efficiency,
			ROUND(AVG([Avail]),0) AS [Availability],
			CASE WHEN AVG([Avail]) IS NULL OR AVG([Avail]) = 0
				THEN 0
				ELSE ROUND((AVG([AE])/AVG([Avail])) * 100,0)
				END  AS Utilization
		FROM BAG.[CONOPS_BAG_SP_SHOVEL_ASSET_EFFICIENCY_V] WITH (NOLOCK)
		WHERE shiftflag = @SHIFT
 
		SELECT
			[Hr] AS [DateTime],
			[AE] AS Efficiency,
			[Avail] AS [Availability],
			CASE WHEN Avail IS NULL OR Avail = 0
				THEN 0
				ELSE ROUND(([AE]/[Avail]) * 100,0)
				END  AS Utilization
		FROM BAG.[CONOPS_BAG_SP_SHOVEL_ASSET_EFFICIENCY_V] WITH (NOLOCK)
		WHERE shiftflag = @SHIFT
		ORDER BY [HOS]

	END

	ELSE IF @SITE = 'CVE'
	BEGIN

		SELECT
			ROUND(AVG([AE]),0) AS Efficiency,
			ROUND(AVG([Avail]),0) AS [Availability],
			CASE WHEN AVG([Avail]) IS NULL OR AVG([Avail]) = 0
				THEN 0
				ELSE ROUND((AVG([AE])/AVG([Avail])) * 100,0)
				END  AS Utilization
		FROM CER.[CONOPS_CER_SP_SHOVEL_ASSET_EFFICIENCY_V] WITH (NOLOCK)
		WHERE shiftflag = @SHIFT
 
		SELECT
			[Hr] AS [DateTime],
			[AE] AS Efficiency,
			[Avail] AS [Availability],
			CASE WHEN Avail IS NULL OR Avail = 0
				THEN 0
				ELSE ROUND(([AE]/[Avail]) * 100,0)
				END  AS Utilization
		FROM CER.[CONOPS_CER_SP_SHOVEL_ASSET_EFFICIENCY_V] WITH (NOLOCK)
		WHERE shiftflag = @SHIFT
		ORDER BY [HOS]

	END

	ELSE IF @SITE = 'CHN'
	BEGIN

		SELECT
			ROUND(AVG([AE]),0) AS Efficiency,
			ROUND(AVG([Avail]),0) AS [Availability],
			CASE WHEN AVG([Avail]) IS NULL OR AVG([Avail]) = 0
				THEN 0
				ELSE ROUND((AVG([AE])/AVG([Avail])) * 100,0)
				END  AS Utilization
		FROM CHI.[CONOPS_CHI_SP_SHOVEL_ASSET_EFFICIENCY_V] WITH (NOLOCK)
		WHERE shiftflag = @SHIFT
 
		SELECT
			[Hr] AS [DateTime],
			[AE] AS Efficiency,
			[Avail] AS [Availability],
			CASE WHEN Avail IS NULL OR Avail = 0
				THEN 0
				ELSE ROUND(([AE]/[Avail]) * 100,0)
				END  AS Utilization
		FROM CHI.[CONOPS_CHI_SP_SHOVEL_ASSET_EFFICIENCY_V] WITH (NOLOCK)
		WHERE shiftflag = @SHIFT
		ORDER BY [HOS]

	END

	ELSE IF @SITE = 'CMX'
	BEGIN

		SELECT
			ROUND(AVG([AE]),0) AS Efficiency,
			ROUND(AVG([Avail]),0) AS [Availability],
			CASE WHEN AVG([Avail]) IS NULL OR AVG([Avail]) = 0
				THEN 0
				ELSE ROUND((AVG([AE])/AVG([Avail])) * 100,0)
				END  AS Utilization
		FROM CLI.[CONOPS_CLI_SP_SHOVEL_ASSET_EFFICIENCY_V] WITH (NOLOCK)
		WHERE shiftflag = @SHIFT
 
		SELECT
			[Hr] AS [DateTime],
			[AE] AS Efficiency,
			[Avail] AS [Availability],
			CASE WHEN Avail IS NULL OR Avail = 0
				THEN 0
				ELSE ROUND(([AE]/[Avail]) * 100,0)
				END  AS Utilization
		FROM CLI.[CONOPS_CLI_SP_SHOVEL_ASSET_EFFICIENCY_V] WITH (NOLOCK)
		WHERE shiftflag = @SHIFT
		ORDER BY [HOS]

	END

	ELSE IF @SITE = 'MOR'
	BEGIN

		SELECT
			ROUND(AVG([AE]),0) AS Efficiency,
			ROUND(AVG([Avail]),0) AS [Availability],
			CASE WHEN AVG([Avail]) IS NULL OR AVG([Avail]) = 0
				THEN 0
				ELSE ROUND((AVG([AE])/AVG([Avail])) * 100,0)
				END  AS Utilization
		FROM MOR.[CONOPS_MOR_SP_SHOVEL_ASSET_EFFICIENCY_V] WITH (NOLOCK)
		WHERE shiftflag = @SHIFT
 
		SELECT
			[Hr] AS [DateTime],
			[AE] AS Effic