
/******************************************************************  
* PROCEDURE	: dbo.LoadAndHaulOverview_TruckAssetEfficiency_Get
* PURPOSE	: Get data for Truck Asset Efficiency Card
* NOTES		: 
* CREATED	: jrodulfa, 02 Dec 2022
* SAMPLE	: 
	1. EXEC dbo.LoadAndHaulOverview_TruckAssetEfficiency_Get 'CURR', 'MOR'
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {02 Dec 2022}		{jrodulfa}		{Initial Created} 
* {05 Dec 2022}		{sxavier}		{Select dialog that will be used} 
* {12 Dec 2022}		{jrodulfa}		{Added Operator Image URL.} 
* {11 Jan 2023}		{jrodulfa}		{Implement Bagdad data.} 
* {25 Jan 2023}		{jrodulfa}		{Implement Safford data.} 
* {27 Jan 2023}		{jrodulfa}		{Change SAF sitecode to SAM.}
* {03 Feb 2023}		{jrodulfa}		{Implement Chino Data.}
* {10 Feb 2023}		{mbote}   		{Implement Cerro Verde Data.}
* {06 Sep 2023}		{ggosal1}   	{Add Asset Efficiency Target}
* {03 Jan 2024}		{lwasini}   	{Added TYR}
* {23 Jan 2024}		{lwasini}		{Add ABR}
*******************************************************************/ 
CREATE PROCEDURE [dbo].[LoadAndHaulOverview_TruckAssetEfficiency_Get] 
(	
	@SHIFT VARCHAR(4),
	@SITE VARCHAR(4)
)
AS                        
BEGIN          

BEGIN TRY

	IF @SITE = 'BAG'
	BEGIN

		SELECT 
			ROUND(ISNULL([ae].overall_efficiency,0),0) AS OverallEfficiency, 
			ROUND(ISNULL([ae].efficiency,0),0) AS Efficiency,
			ROUND(ISNULL([aet].TruckEfficiencyTarget,0),0) AS EfficiencyTarget,
			ROUND(ISNULL([ae].[availability],0),0) AS [Availability], 
			ROUND(ISNULL([aet].TruckAvailabilityTarget,0),0) AS [AvailabilityTarget], 
			ROUND(ISNULL([ae].use_of_availability,0),0) AS Utilization,
			ROUND(ISNULL([aet].TruckUtilizationTarget,0),0) AS UtilizationTarget
		FROM BAG.[CONOPS_BAG_TRUCK_ASSET_EFFICIENCY_V] [ae] WITH (NOLOCK)
		LEFT JOIN [BAG].[CONOPS_BAG_EQMT_ASSET_EFFICIENCY_TARGET_V] [aet]
			ON [ae].siteflag = [aet].SITEFLAG
		WHERE [ae].shiftflag = @SHIFT 

	END

	ELSE IF @SITE = 'CVE'
	BEGIN

		SELECT 
			ROUND(ISNULL([ae].overall_efficiency,0),0) AS OverallEfficiency, 
			ROUND(ISNULL([ae].efficiency,0),0) AS Efficiency,
			ROUND(ISNULL([aet].TruckEfficiencyTarget,0),0) AS EfficiencyTarget,
			ROUND(ISNULL([ae].[availability],0),0) AS [Availability], 
			ROUND(ISNULL([aet].TruckAvailabilityTarget,0),0) AS [AvailabilityTarget], 
			ROUND(ISNULL([ae].use_of_availability,0),0) AS Utilization,
			ROUND(ISNULL([aet].TruckUtilizationTarget,0),0) AS UtilizationTarget
		FROM CER.[CONOPS_CER_TRUCK_ASSET_EFFICIENCY_V] [ae] WITH (NOLOCK)
		LEFT JOIN [CER].[CONOPS_CER_EQMT_ASSET_EFFICIENCY_TARGET_V] [aet]
			ON [ae].siteflag = [aet].SITEFLAG
		WHERE [ae].shiftflag = @SHIFT 

	END

	ELSE IF @SITE = 'CHN'
	BEGIN

		SELECT 
			ROUND(ISNULL([ae].overall_efficiency,0),0) AS OverallEfficiency, 
			ROUND(ISNULL([ae].efficiency,0),0) AS Efficiency,
			ROUND(ISNULL([aet].TruckEfficiencyTarget,0),0) AS EfficiencyTarget,
			ROUND(ISNULL([ae].[availability],0),0) AS [Availability], 
			ROUND(ISNULL([aet].TruckAvailabilityTarget,0),0) AS [AvailabilityTarget], 
			ROUND(ISNULL([ae].use_of_availability,0),0) AS Utilization,
			ROUND(ISNULL([aet].TruckUtilizationTarget,0),0) AS UtilizationTarget
		FROM CHI.[CONOPS_CHI_TRUCK_ASSET_EFFICIENCY_V] [ae] WITH (NOLOCK)
		LEFT JOIN [CHI].[CONOPS_CHI_EQMT_ASSET_EFFICIENCY_TARGET_V] [aet]
			ON [ae].siteflag = [aet].SITEFLAG
		WHERE [ae].shiftflag = @SHIFT 

	END

	ELSE IF @SITE = 'CMX'
	BEGIN

		SELECT 
			ROUND(ISNULL([ae].overall_efficiency,0),0) AS OverallEfficiency, 
			ROUND(ISNULL([ae].efficiency,0),0) AS Efficiency,
			ROUND(ISNULL([aet].TruckEfficiencyTarget,0),0) AS EfficiencyTarget,
			ROUND(ISNULL([ae].[availability],0),0) AS [Availability], 
			ROUND(ISNULL([aet].TruckAvailabilityTarget,0),0) AS [AvailabilityTarget], 
			ROUND(ISNULL([ae].use_of_availability,0),0) AS Utilization,
			ROUND(ISNULL([aet].TruckUtilizationTarge