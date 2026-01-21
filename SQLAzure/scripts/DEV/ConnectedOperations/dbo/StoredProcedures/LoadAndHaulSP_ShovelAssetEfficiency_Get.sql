
/******************************************************************  
* PROCEDURE	: dbo.LoadAndHaulSP_ShovelAssetEfficiency_Get
* PURPOSE	: 
* NOTES		: 
* CREATED	: jrodulfa, 22 Dec 2022
* SAMPLE	: 
	1. EXEC dbo.LoadAndHaulSP_ShovelAssetEfficiency_Get 'CURR', 'MOR',NULL,NULL,NULL
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {22 Dec 2022}		{jrodulfa}		{Initial Created} 
* {23 Dec 2022}		{sxavier}		{Rename field} 
* {18 Sep 2023}		{lwasini}		{Add Paramter EQMT,EQMTTYPE,STATUS}
* {10 Jan 2024}		{lwasini}		{Add TYR} 
* {23 Jan 2024}		{lwasini}		{Add ABR}
*******************************************************************/ 
CREATE PROCEDURE [dbo].[LoadAndHaulSP_ShovelAssetEfficiency_Get] 
(	
	@SHIFT VARCHAR(4),
	@SITE VARCHAR(4),
	@STATUS NVARCHAR(MAX),
	@EQMT NVARCHAR(MAX),
	@EQMTTYPE NVARCHAR(MAX)
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
			AVG([AE]) AS Efficiency,
			AVG([Avail]) AS [Availability],
			CASE WHEN AVG(Avail) IS NULL OR AVG(Avail) = 0
				THEN 0
				ELSE ROUND((AVG([AE])/AVG([Avail])) * 100,0)
				END  AS Utilization
		FROM BAG.[CONOPS_BAG_SP_SHOVEL_ASSET_EFFICIENCY_V] WITH (NOLOCK)
		WHERE shiftflag = @SHIFT
		AND (Equipment IN (SELECT TRIM(value) FROM STRING_SPLIT(@EQMT, ',')) OR ISNULL(@EQMT, '') = '')
		AND (eqmttype IN (SELECT TRIM(value) FROM STRING_SPLIT(@EQMTTYPE, ',')) OR ISNULL(@EQMTTYPE, '') = '')
		AND (StatusName IN (SELECT TRIM(value) FROM STRING_SPLIT(UPPER(@STATUS), ',')) OR ISNULL(@STATUS, '') = '')
		GROUP BY [Hr],[HOS]
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
			AVG([AE]) AS Efficiency,
			AVG([Avail]) AS [Availability],
			CASE WHEN AVG(Avail) IS NULL OR AVG(Avail) = 0
				THEN 0
				ELSE ROUND((AVG([AE])/AVG([Avail])) * 100,0)
				END  AS Utilization
		FROM CER.[CONOPS_CER_SP_SHOVEL_ASSET_EFFICIENCY_V] WITH (NOLOCK)
		WHERE shiftflag = @SHIFT
		AND (Equipment IN (SELECT TRIM(value) FROM STRING_SPLIT(@EQMT, ',')) OR ISNULL(@EQMT, '') = '')
		AND (eqmttype IN (SELECT TRIM(value) FROM STRING_SPLIT(@EQMTTYPE, ',')) OR ISNULL(@EQMTTYPE, '') = '')
		AND (StatusName IN (SELECT TRIM(value) FROM STRING_SPLIT(UPPER(@STATUS), ',')) OR ISNULL(@STATUS, '') = '')
		GROUP BY [Hr],[HOS]
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
			AVG([AE]) AS Efficiency,
			AVG([Avail]) AS [Availability],
			CASE WHEN AVG(Avail) IS NULL OR AVG(Avail) = 0
				THEN 0
				ELSE ROUND((AVG([AE])/AVG([Avail])) * 100,0)
				END  AS Utilization
		FROM CHI.[CONOPS_CHI_SP_SHOVEL_ASSET_EFFICIENCY_V] WITH (NOLOCK)
		WHERE shiftflag = @SHIFT
		AND (Equipment IN (SELECT TRIM(value) FROM STRING_SPLIT(@EQMT, ',')) OR ISNULL(@EQMT, '') = '')
		AND (eqmttype IN (SELECT TRIM(value) FROM STRING_SPLIT(@EQMTTYPE, ',')) OR ISNULL(@EQMTTYPE, '') = '')
		AND (St