

/******************************************************************  
* PROCEDURE	: dbo.LoadAndHaulSP_TotalMaterialMined_Get
* PURPOSE	: 
* NOTES		: 
* CREATED	: lwasini, 25 Oct 2022
* SAMPLE	: 
	1. EXEC dbo.LoadAndHaulSP_TotalMaterialMined_Get 'PREV', 'MOR', 'DELAY, SPARE', NULL,NULL
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {25 Oct 2022}		{lwasini}		{Initial Created}  
* {13 Dec 2022}		{sxavier}		{Rename field and comment count ShovelToWatch} 
* {25 Jan 2022}		{sxavier}		{Order by OffTarget Desc} 
* {31 Aug 2023}		{lwasini}		{Add Parameter Equipment Type} 
* {18 Sep 2023}		{ggosal1}		{Add Availability} 
* {28 Nov 2023}		{lwasini}		{Add OperatorId}
* {10 Jan 2024}		{lwasini}		{Add TYR} 
* {23 Jan 2024}		{lwasini}		{Add ABR}
* {23 Jan 2024}		{ggosal1}		{Add Material Delivered & Hang Time to Detail}
*******************************************************************/ 
CREATE PROCEDURE [dbo].[LoadAndHaulSP_TotalMaterialMined_Get] 
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
			ShovelId AS [Name], 
			Operator AS OperatorName,
			OperatorImageURL as ImageUrl,
			RIGHT('0000000000' + [OperatorId], 10) OperatorId,
			ROUND(TotalMaterialMined/1000,1) as TotalMaterialMined,
			ROUND(TotalMaterialMinedTarget/1000,1) as TotalMaterialMinedTarget,
			ROUND(Offtarget/1000,1) as OffTarget,
			ROUND(DeltaC,1) AS DeltaC,
			DeltaCTarget,
			IdleTime,
			IdleTimeTarget,
			Spotting,
			SpottingTarget,
			Loading,
			LoadingTarget,
			Dumping,
			DumpingTarget,
			ReasonIdx,
			Reasons AS Reason,
			TonsPerReadyHour AS TonsPerReadyHour,
			TonsPerReadyHourTarget AS TonsPerReadyHourTarget,
			ROUND(TotalMaterialMoved/1000.0,1) AS TotalMaterialMoved,
			ROUND(TotalMaterialMovedTarget/1000.0,1) AS TotalMaterialMovedTarget,
			ROUND(HangTime,2) AS HangTime,
			ROUND(HangTimeTarget,2) AS HangTimeTarget,
			ROUND(NumberOfLoads,0) AS NumberOfLoads,
			ROUND(NumberOfLoadsTarget,0) AS NumberOfLoadsTarget,
			ROUND(AssetEfficiency,0) AS AssetEfficiency,
			ROUND(AssetEfficiencyTarget,0) AS AssetEfficiencyTarget,
			ROUND(Payload,0) AS Payload,
			PayloadTarget,
			ROUND(Availability,0) AS Availability,
			ROUND(AvailabilityTarget,0) AS AvailabilityTarget
		FROM BAG.[CONOPS_BAG_SP_TOTAL_MATERIAL_MINED_V] (NOLOCK)
		WHERE shiftflag = @SHIFT
			AND (shovelid IN (SELECT TRIM(value) FROM STRING_SPLIT(@EQMT, ',')) OR ISNULL(@EQMT, '') = '')
			AND (eqmttype IN (SELECT TRIM(value) FROM STRING_SPLIT(@EQMTTYPE, ',')) OR ISNULL(@EQMTTYPE, '') = '')
			AND (eqmtcurrstatus IN (SELECT TRIM(value) FROM STRING_SPLIT(UPPER(@STATUS), ',')) OR ISNULL(@STATUS, '') = '')
		ORDER BY OffTarget DESC;

	END

	ELSE IF @SITE = 'CVE'
	BEGIN

		SELECT 
			ShovelId AS [Name], 
			Operator AS OperatorName,
			OperatorImageURL as ImageUrl,
			RIGHT('0000000000' + [OperatorId], 10) OperatorId,
			ROUND(TotalMaterialMined/1000,1) as TotalMaterialMined,
			ROUND(TotalMaterialMinedTarget/1000,1) as TotalMaterialMinedTarget,
			ROUND(Offtarget/1000,1) as OffTarget,
			ROUND(DeltaC,1) AS DeltaC,
			DeltaCTarget,
			IdleTime,
			IdleTimeTarget,
			Spotting,
			SpottingTarget,
			Loading,
			LoadingTarget,
			Dumping,
			DumpingTarget,
			ReasonIdx,
			Reasons AS Reason,
			TonsPerReadyHour AS TonsPerReadyHour,
			TonsPerReadyHourTarget AS TonsPerReadyHourTarget,
			ROUND(TotalMaterialMoved/1000.0,1) AS TotalMaterialMoved,
			ROUND(TotalMaterialMovedTarget/1000.0,1) AS TotalMaterialMovedTarget,
			ROUND(HangTime,2) AS HangTime,
			ROUND(HangTimeTarget,2) AS HangTimeTarget,
			ROUND(NumberOfLoads,0) AS NumberOfLoads,
			ROUND(NumberOfLoadsTarget,0) AS NumberOfLoadsTarget,
			ROUND(AssetEfficiency,0) AS AssetEfficiency,
			ROUND(AssetEfficiencyTarg