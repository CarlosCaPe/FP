




/******************************************************************  
* PROCEDURE	: dbo.LoadAndHaulOverview_TruckAssetEfficiency_Get
* PURPOSE	: Get data for Truck Asset Efficiency Card
* NOTES		: 
* CREATED	: jrodulfa, 02 Dec 2022
* SAMPLE	: 
	1. EXEC dbo.LoadAndHaulOverview_TruckAssetEfficiency_Get 'CURR', 'CVE'
	
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
*******************************************************************/ 
CREATE PROCEDURE [dbo].[zzz_LoadAndHaulOverview_TruckAssetEfficiency_Get_OLD] 
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

	SELECT 
		ROUND(ISNULL([ae].overall_efficiency,0),0) AS OverallEfficiency, 
		ROUND(ISNULL([ae].efficiency,0),0) AS Efficiency, 
		ROUND(ISNULL([ae].[availability],0),0) AS [Availability], 
		ROUND(ISNULL([ae].use_of_availability,0),0) AS Utilization
	FROM [dbo].[CONOPS_LH_TRUCK_ASSET_EFFICIENCY_V] [ae] WITH (NOLOCK)
	WHERE [ae].shiftflag = @SHIFT AND
		  [ae].siteflag = @SITE;
		  
SET NOCOUNT OFF
END

