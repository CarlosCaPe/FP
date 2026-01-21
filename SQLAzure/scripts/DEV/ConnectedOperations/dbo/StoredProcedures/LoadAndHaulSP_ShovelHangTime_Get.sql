

/******************************************************************  
* PROCEDURE	: dbo.LoadAndHaulSP_ShovelHangTime_Get
* PURPOSE	: 
* NOTES		: 
* CREATED	: lwasini, 08 Sep 2023
* SAMPLE	: 
	1. EXEC dbo.LoadAndHaulSP_ShovelHangTime_Get 'CURR', 'MOR',NULL,NULL,NULL
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {08 Sep 2023}		{lwasini}		{Initial Created} 
* {19 Sep 2023}		{sxavier}		{Remove top 5 and rename field} 
* {28 Nov 2023}		{lwasini}		{Add OperatorId}
* {10 Jan 2024}		{lwasini}		{Add TYR} 
* {23 Jan 2024}		{lwasini}		{Add ABR}
* {23 Jan 2024}		{ggosal1}		{Add Material Delivered & Hang Time to Detail} 
* {15 Apr 2024}		{lwasini}		{Change PopUp View to Table}
*******************************************************************/ 
CREATE PROCEDURE [dbo].[LoadAndHaulSP_ShovelHangTime_Get] 
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

		SELECT
			[a].ShovelID AS [Name],
			ROUND([a].Hangtime,2) AS DataActual,
			[a].HangtimeTarget AS DataTarget,
			[a].Operator AS OperatorName,
			[a].OperatorImageURL as ImageUrl,
			RIGHT('0000000000' + [a].[OperatorId], 10) OperatorId,
			ROUND([a].TotalMaterialMined/1000.0,1) AS TotalMaterialMined,
			ROUND([a].TotalMaterialMinedTarget/1000.0,1) AS TotalMaterialMinedTarget,
			ROUND([a].DeltaC,1) As DeltaC,
			[a].DeltaCTarget,
			[a].IdleTime,
			[a].IdleTimeTarget,
			[a].Spotting,
			[a].SpottingTarget,
			[a].Loading,
			[a].LoadingTarget,
			[a].Dumping,
			[a].DumpingTarget,
			ROUND([a].Payload,0) AS Payload,
			[a].PayloadTarget,
			ROUND([a].NumberOfLoads,0) AS NumberOfLoads,
			ROUND([a].NumberOfLoadsTarget,0) AS NumberOfLoadsTarget,
			ROUND([a].AssetEfficiency,0) AS AssetEfficiency,
			ROUND([a].AssetEfficiencyTarget,0) AS AssetEfficiencyTarget,
			[a].TonsPerReadyHour AS TonsPerReadyHour,
			[a].TonsPerReadyHourTarget AS TonsPerReadyHourTarget,
			ROUND([a].TotalMaterialMoved/1000.0,1) AS TotalMaterialMoved,
			ROUND([a].TotalMaterialMovedTarget/1000.0,1) AS TotalMaterialMovedTarget,
			ROUND([a].HangTime,2) AS HangTime,
			ROUND([a].HangTimeTarget,2) AS HangTimeTarget,
			[a].ReasonID AS ReasonIdx,
			[a].ReasonDesc AS Reason
		FROM [bag].[CONOPS_BAG_SHOVEL_POPUP] a WITH (NOLOCK)
		LEFT JOIN [bag].[CONOPS_BAG_SHOVEL_INFO_V] [b]
		ON [a].shiftflag = [b].shiftflag AND [a].shovelid = [b].ShovelID
		WHERE a.shiftflag = @SHIFT
			AND (a.ShovelID IN (SELECT TRIM(value) FROM STRING_SPLIT(@EQMT, ',')) OR ISNULL(@EQMT, '') = '')
			AND (a.eqmttype IN (SELECT TRIM(value) FROM STRING_SPLIT(@EQMTTYPE, ',')) OR ISNULL(@EQMTTYPE, '') = '')
			AND (StatusName IN (SELECT TRIM(value) FROM STRING_SPLIT(UPPER(@STATUS), ',')) OR ISNULL(@STATUS, '') = '')
		ORDER BY [a].Hangtime DESC;

	END

	ELSE IF @SITE = 'CVE'
	BEGIN

		SELECT
			[a].ShovelID AS [Name],
			ROUND([a].Hangtime,2) AS DataActual,
			[a].HangtimeTarget AS DataTarget,
			[a].Operator AS OperatorName,
			[a].OperatorImageURL as ImageUrl,
			RIGHT('0000000000' + [a].[OperatorId], 10) OperatorId,
			ROUND([a].TotalMaterialMined/1000.0,1) AS TotalMaterialMined,
			ROUND([a].TotalMaterialMinedTarget/1000.0,1) AS TotalMaterialMinedTarget,
			ROUND([a].DeltaC,1) As DeltaC,
			[a].DeltaCTarget,
			[a].IdleTime,
			[a].IdleTimeTarget,
			[a].Spotting,
			[a].SpottingTarget,
			[a].Loading,
			[a].LoadingTarget,
			[a].Dumping,
			[a].DumpingTarget,
			ROUND([a].Payload,0) AS Payload,
			[a].PayloadTarget,
			ROUND([a].NumberOfLoads,0) AS NumberOfLoads,
			ROUND([a].NumberOfLoadsTarget,0) AS NumberOfLoadsTarget,
			ROUND([a].AssetEfficiency,0) AS AssetEfficiency,
			ROUND([a].AssetEfficiencyTarget,0) AS AssetEfficiencyTarget,
			[a].TonsPerReadyHour AS TonsPerReadyHour,
			[a].TonsPerReadyHourTarget AS TonsPerReadyH