



/******************************************************************  
* PROCEDURE	: dbo.LoadAndHaulTP_TruckAssetEfficiency_Get
* PURPOSE	: 
* NOTES		: 
* CREATED	: jrodulfa, 22 Dec 2022
* SAMPLE	: 
	1. EXEC dbo.LoadAndHaulTP_TruckAssetEfficiency_Get 'PREV', 'MOR'
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {22 Dec 2022}		{jrodulfa}		{Initial Created} 
* {23 Dec 2022}		{sxavier}		{Rename field} 
* {06 Jan 2023}		{jrodulfa}		{Implement Bagdad data} 
* {13 Jan 2023}		{jrodulfa}		{Initial implementation of Safford data} 
* {27 Jan 2023}		{jrodulfa}		{Change SAF sitecode to SAM.}
* {27 Jan 2023}		{jrodulfa}		{Implement Chino data} 
* {02 Feb 2023}		{mbote}		    {Implement Cerro Verde data}
*******************************************************************/ 
CREATE PROCEDURE [dbo].[zzz_LoadAndHaulTP_TruckAssetEfficiency_Get] 
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
				END AS Utilization
		FROM BAG.[CONOPS_BAG_TP_TRUCK_ASSET_EFFICIENCY_V] WITH (NOLOCK)
		WHERE shiftflag = @SHIFT 
 
		SELECT
			[Hr] AS [DateTime],
			[AE] AS Efficiency,
			[Avail] AS [Availability],
			CASE WHEN Avail IS NULL OR Avail = 0
				THEN 0
				ELSE ROUND(([AE]/[Avail]) * 100,0)
				END AS Utilization
		FROM BAG.[CONOPS_BAG_TP_TRUCK_ASSET_EFFICIENCY_V] WITH (NOLOCK)
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
				END AS Utilization
		FROM CER.[CONOPS_CER_TP_TRUCK_ASSET_EFFICIENCY_V] WITH (NOLOCK)
		WHERE shiftflag = @SHIFT 
 
		SELECT
			[Hr] AS [DateTime],
			[AE] AS Efficiency,
			[Avail] AS [Availability],
			CASE WHEN Avail IS NULL OR Avail = 0
				THEN 0
				ELSE ROUND(([AE]/[Avail]) * 100,0)
				END AS Utilization
		FROM CER.[CONOPS_CER_TP_TRUCK_ASSET_EFFICIENCY_V] WITH (NOLOCK)
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
				END AS Utilization
		FROM CHI.[CONOPS_CHI_TP_TRUCK_ASSET_EFFICIENCY_V] WITH (NOLOCK)
		WHERE shiftflag = @SHIFT 
 
		SELECT
			[Hr] AS [DateTime],
			[AE] AS Efficiency,
			[Avail] AS [Availability],
			CASE WHEN Avail IS NULL OR Avail = 0
				THEN 0
				ELSE ROUND(([AE]/[Avail]) * 100,0)
				END AS Utilization
		FROM CHI.[CONOPS_CHI_TP_TRUCK_ASSET_EFFICIENCY_V] WITH (NOLOCK)
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
				END AS Utilization
		FROM CLI.[CONOPS_CLI_TP_TRUCK_ASSET_EFFICIENCY_V] WITH (NOLOCK)
		WHERE shiftflag = @SHIFT 
 
		SELECT
			[Hr] AS [DateTime],
			[AE] AS Efficiency,
			[Avail] AS [Availability],
			CASE WHEN Avail IS NULL OR Avail = 0
				THEN 0
				ELSE ROUND(([AE]/[Avail]) * 100,0)
				END AS Utilization
		FROM CLI.[CONOPS_CLI_TP_TRUCK_ASSET_EFFICIENCY_V] WITH (NOLOCK)
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