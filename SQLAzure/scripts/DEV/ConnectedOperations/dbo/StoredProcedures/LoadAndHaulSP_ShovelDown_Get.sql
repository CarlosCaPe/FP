

/******************************************************************  
* PROCEDURE	: dbo.LoadAndHaulSP_ShovelDown_Get
* PURPOSE	: 
* NOTES		: 
* CREATED	: jrodulfa, 19 Dec 2022
* SAMPLE	: 
	1. EXEC dbo.LoadAndHaulSP_ShovelDown_Get 'CURR', 'MOR',NULL,NULL,NULL
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {19 Dec 2022}		{jrodulfa}		{Initial Created} 
* {21 Dec 2022}		{sxavier}		{Rename field} 
* {10 Jan 2023}		{jrodulfa}		{Added new item in Shovel Dialog} 
* {14 Sep 2023}		{lwasini}		{Add Parameter Equipment & Equipment Type, Status} 
* {18 Sep 2023}		{ggosal1}		{Add Availability} 
* {28 Nov 2023}		{lwasini}		{Add OperatorId} 
* {10 Jan 2024}		{lwasini}		{Add TYR} 
* {23 Jan 2024}		{lwasini}		{Add ABR}
* {23 Jan 2024}		{ggosal1}		{Add Material Delivered & Hang Time to Detail} 
* {15 Apr 2024}		{lwasini}		{Change PopUp View to Table}
*******************************************************************/ 
CREATE PROCEDURE [dbo].[LoadAndHaulSP_ShovelDown_Get] 
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

		SELECT [sd].ShovelID [Name],
			[dialog].Operator [OperatorName],
			[dialog].OperatorImageURL [ImageUrl],
			LEFT(RIGHT([dialog].OperatorImageURL,14),10) OperatorId,
			[dialog].ReasonId AS ReasonIdx,
			[dialog].ReasonDesc AS Reason,
			ROUND([Actualvalue] / 1000,1) AS TotalMaterialMined,
			ROUND(ShiftTarget / 1000,1) AS TotalMaterialMinedTarget,
			ROUND([OffTarget] / 1000,1) OffTarget,
			ROUND([dialog].DeltaC,1) As DeltaC,
			[dialog].DeltaCTarget,
			[dialog].IdleTime,
			[dialog].IdleTimeTarget,
			[dialog].Spotting,
			[dialog].SpottingTarget,
			[dialog].Loading,
			[dialog].LoadingTarget,
			[dialog].Dumping,
			[dialog].DumpingTarget,
			ROUND([dialog].NumberOfLoads,0) AS NumberOfLoads,
			ROUND([dialog].NumberOfLoadsTarget,0) As NumberOfLoadsTarget,
			ROUND([dialog].AssetEfficiency,0) AS AssetEfficiency,
			ROUND([dialog].AssetEfficiencyTarget,0) As AssetEfficiencyTarget,
			[dialog].TonsPerReadyHour AS TonsPerReadyHour,
			[dialog].TonsPerReadyHourTarget [TonsPerReadyHourTarget],
			ROUND([dialog].TotalMaterialMoved/1000.0,1) AS TotalMaterialMoved,
			ROUND([dialog].TotalMaterialMovedTarget/1000.0,1) AS TotalMaterialMovedTarget,
			ROUND([dialog].HangTime,2) AS HangTime,
			ROUND([dialog].HangTimeTarget,2) AS HangTimeTarget,
			ROUND([dialog].Payload,0) AS Payload,
			[dialog].PayloadTarget,
			ROUND([dialog].Availability,0) AS Availability,
			ROUND([dialog].AvailabilityTarget,0) As AvailabilityTarget
		FROM BAG.[CONOPS_BAG_SHOVEL_DOWN_V] [sd] WITH (NOLOCK)
		LEFT JOIN BAG.[CONOPS_BAG_SHOVEL_POPUP] [dialog] WITH (NOLOCK)
			ON [sd].shiftflag = [dialog].shiftflag
			AND [sd].ShovelID = [dialog].[ShovelID]
		WHERE [sd].shiftflag = @SHIFT
		AND (sd.ShovelID IN (SELECT TRIM(value) FROM STRING_SPLIT(@EQMT, ',')) OR ISNULL(@EQMT, '') = '')
		AND (eqmttype IN (SELECT TRIM(value) FROM STRING_SPLIT(@EQMTTYPE, ',')) OR ISNULL(@EQMTTYPE, '') = '')
		AND (sd.StatusName IN (SELECT TRIM(value) FROM STRING_SPLIT(UPPER(@STATUS), ',')) OR ISNULL(@STATUS, '') = '')

	END

	ELSE IF @SITE = 'CVE'
	BEGIN

		SELECT [sd].ShovelID [Name],
			[dialog].Operator [OperatorName],
			[dialog].OperatorImageURL [ImageUrl],
			LEFT(RIGHT([dialog].OperatorImageURL,14),10) OperatorId,
			[dialog].ReasonId AS ReasonIdx,
			[dialog].ReasonDesc AS Reason,
			ROUND([Actualvalue] / 1000,1) AS TotalMaterialMined,
			ROUND(ShiftTarget / 1000,1) AS TotalMaterialMinedTarget,
			ROUND([OffTarget] / 1000,1) OffTarget,
			ROUND([dialog].DeltaC,1) As DeltaC,
			[dialog].DeltaCTarget,
			[dialog].IdleTime,
			[dialog].IdleTimeTarget,
			[dialog].Spotting,
			[dialog].SpottingTarget,
			[dialog].Loading,
			[dialog].LoadingTarget,
			[dialog].D