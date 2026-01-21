


/******************************************************************  
* PROCEDURE	: dbo.LoadAndHaulOverview_ShovelToWatch_Get
* PURPOSE	: 
* NOTES		: 
* CREATED	: lwasini, 25 Oct 2022
* SAMPLE	: 
	1. EXEC dbo.LoadAndHaulOverview_ShovelToWatch_Get 'CURR', 'CVE'
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {25 Oct 2022}		{lwasini}		{Initial Created}  
* {25 Jan 2022}		{sxavier}		{Order by OffTarget Desc}  
* {26 Jan 2023}		{jrodulfa}		{Implement Safford data.}
* {27 Jan 2023}		{jrodulfa}		{Change SAF sitecode to SAM.}
* {06 Feb 2023}		{jrodulfa}		{Implement Chino Data.}
* {10 Feb 2023}		{jrodulfa}		{Implement Cerro Verde Data.}
*******************************************************************/ 
CREATE PROCEDURE [dbo].[LoadAndHaulOverview_ShovelToWatch_Get_OLD] 
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
		ShovelId, 
		Operator AS OperatorName,
		OperatorImageURL as ImageUrl,
		ROUND(TotalMaterialMined/1000,1) as Actual,
		ROUND(TotalMaterialMinedTarget/1000,1) as [Target],
		ROUND(Offtarget/1000,1) as OffTarget,
		ROUND(DeltaC,1) As DeltaC,
		DeltaCTarget,
		IdleTime,
		IdleTimeTarget,
		Spotting,
		SpottingTarget,
		Loading,
		LoadingTarget,
		Dumping,
		DumpingTarget,
		ROUND(Payload,0) As Payload,
		PayloadTarget,
		ROUND(NumberofLoads,0) AS NumberofLoads,
		ROUND(NumberofLoadsTarget,0) AS NumberofLoadsTarget,
		TonsPerReadyHour/1000 AS TonsPerReadyHour,
		TonsPerReadyHourTarget/1000 AS TonsPerReadyHourTarget,
		ROUND(AssetEfficiency,0) As AssetEfficiency,
		ROUND(AssetEfficiencyTarget,0) As AssetEfficiencyTarget,
		reasonidx AS ReasonIdx,
		reasons As Reason
	FROM 
		[dbo].[CONOPS_LH_SHOVEL_TO_WATCH_V] (NOLOCK)
	WHERE 
		shiftflag = @SHIFT
		AND siteflag = @SITE
	ORDER BY OffTarget DESC;

SET NOCOUNT OFF
END

