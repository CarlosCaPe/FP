




/******************************************************************  
* PROCEDURE	: dbo.LoadAndHaulTP_TruckAssetEfficiency_Get
* PURPOSE	: 
* NOTES		: 
* CREATED	: jrodulfa, 22 Dec 2022
* SAMPLE	: 
	1. EXEC dbo.LoadAndHaulTP_TruckAssetEfficiency_Get 'PREV', 'CVE'
	
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
CREATE PROCEDURE [dbo].[LoadAndHaulTP_TruckAssetEfficiency_Get_OLD] 
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
	       ROUND(AVG([Avail]),0) AS [Availability],
		   ROUND((AVG([AE])/AVG([Avail])) * 100,0) AS Utilization
	FROM [dbo].[CONOPS_LH_TP_TRUCK_ASSET_EFFICIENCY_V] WITH (NOLOCK)
	WHERE shiftflag = @SHIFT AND siteflag = @SITE

	SELECT
		   [Hr] AS [DateTime],
		   [AE] AS Efficiency,
		   [Avail] AS [Availability],
		   [UofA] AS Utilization
	FROM [dbo].[CONOPS_LH_TP_TRUCK_ASSET_EFFICIENCY_V] WITH (NOLOCK)
	WHERE shiftflag = @SHIFT AND siteflag = @SITE
	ORDER BY [HOS]

SET NOCOUNT OFF
END

