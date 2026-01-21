
/******************************************************************  
* PROCEDURE	: dbo.LoadAndHaulOverview_ShovelToWatch_Get
* PURPOSE	: 
* NOTES		: 
* CREATED	: lwasini, 25 Oct 2022
* SAMPLE	: 
	1. EXEC dbo.LoadAndHaulOverview_ShovelToWatch_Get 'CURR', 'MOR'
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {25 Oct 2022}		{lwasini}		{Initial Created}  
* {25 Jan 2022}		{sxavier}		{Order by OffTarget Desc}  
* {17 May 2023}		{lwasini}		{Exclude Shovel in Ready Status}
* {28 Nov 2023}		{lwasini}		{Add OperatorId}
* {10 jan 2024}		{lwasini}		{Add TYR}
* {23 Jan 2024}		{lwasini}		{Add ABR} 
* {08 Oct 2025}		{dbonardo}		{Remove Division by 100 on target actual and off target}
*******************************************************************/ 
CREATE PROCEDURE [dbo].[LoadAndHaulOverview_ShovelToWatch_Get] 
(	
	@SHIFT VARCHAR(4),
	@SITE VARCHAR(4)
)
AS                        
BEGIN          
BEGIN TRY	IF @SITE = 'BAG'
	BEGIN

		SELECT 
			ShovelId, 
			Operator AS OperatorName,
			OperatorImageURL as ImageUrl,
			RIGHT('0000000000' + [OperatorId], 10) OperatorId,
			ROUND(TotalMaterialMined,1) as Actual,
			ROUND(TotalMaterialMinedTarget,1) as [Target],
			ROUND(Offtarget,1) as OffTarget,
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
			TonsPerReadyHour AS TonsPerReadyHour,
			TonsPerReadyHourTarget AS TonsPerReadyHourTarget,
			ROUND(AssetEfficiency,0) As AssetEfficiency,
			ROUND(AssetEfficiencyTarget,0) As AssetEfficiencyTarget,
			ROUND(TotalMaterialMoved/1000.0,1) AS TotalMaterialMoved,
			ROUND(TotalMaterialMovedTarget/1000.0,1) AS TotalMaterialMovedTarget,
			ROUND(HangTime,2) AS HangTime,
			ROUND(HangTimeTarget,2) AS HangTimeTarget,
			reasonidx AS ReasonIdx,
			reasons As Reason
		FROM BAG.[CONOPS_BAG_SHOVEL_TO_WATCH_V] (NOLOCK)
		WHERE shiftflag = @SHIFT
		AND eqmtcurrstatus = 'Ready'
		ORDER BY OffTarget DESC

	END

	ELSE IF @SITE = 'CVE'
	BEGIN

		SELECT 
			ShovelId, 
			Operator AS OperatorName,
			OperatorImageURL as ImageUrl,
			RIGHT('0000000000' + [OperatorId], 10) OperatorId,
			ROUND(TotalMaterialMined,1) as Actual,
			ROUND(TotalMaterialMinedTarget,1) as [Target],
			ROUND(Offtarget,1) as OffTarget,
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
			TonsPerReadyHour AS TonsPerReadyHour,
			TonsPerReadyHourTarget AS TonsPerReadyHourTarget,
			ROUND(AssetEfficiency,0) As AssetEfficiency,
			ROUND(AssetEfficiencyTarget,0) As AssetEfficiencyTarget,
			ROUND(TotalMaterialMoved/1000.0,1) AS TotalMaterialMoved,
			ROUND(TotalMaterialMovedTarget/1000.0,1) AS TotalMaterialMovedTarget,
			ROUND(HangTime,2) AS HangTime,
			ROUND(HangTimeTarget,2) AS HangTimeTarget,
			reasonidx AS ReasonIdx,
			reasons As Reason
		FROM CER.[CONOPS_CER_SHOVEL_TO_WATCH_V] (NOLOCK)
		WHERE shiftflag = @SHIFT
		AND eqmtcurrstatus = 'Ready'
		ORDER BY OffTarget DESC

	END

	ELSE IF @SITE = 'CHN'
	BEGIN

		SELECT 
			ShovelId, 
			Operator AS OperatorName,
			OperatorImageURL as ImageUrl,
			RIGHT('0000000000' + [OperatorId], 10) OperatorId,
			ROUND(TotalMaterialMined,1) as Actual,
			ROUND(TotalMaterialMinedTarget,1) as [Target],
			ROUND(Offtarget,1) as OffTarget,
			ROUND(DeltaC,1) As DeltaC,
			DeltaCTarget,
			IdleTime,
			IdleTimeTarget,
			Spotting,
			SpottingTarget,
			Loading,
			LoadingTarget,
		