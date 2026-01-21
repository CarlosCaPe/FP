

/******************************************************************  
* PROCEDURE	: dbo.LoadAndHaulSP_AveragePayload_Get
* PURPOSE	: 
* NOTES		: 
* CREATED	: jrodulfa, 14 DEC 2022
* SAMPLE	: 
	1. EXEC dbo.LoadAndHaulSP_AveragePayload_Get 'CURR', 'MOR', NULL, NULL,NULL
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {14 Dec 2022}		{jrodulfa}		{Initial Created} 
* {22 Dec 2022}		{jrodulfa}		{Added data for Shovel Detail Dialog box.} 
* {23 Dec 2022}		{sxavier}		{Rename field} 
* {29 Dec 2022}		{sxavier}		{Added reason and reasonId data} 
* {04 Jan 2023}		{jrodulfa}		{Added No. of Loads, AE and TPRH} 
* {31 Aug 2023}		{lwasini}		{Add Parameter Equipment Type} 
* {18 Sep 2023}		{lwasini}		{Add Hourly Payload} 
* {28 Nov 2023}		{lwasini}		{Add OperatorId} 
* {10 jan 2024}		{lwasini}		{Add TYR}
* {23 Jan 2024}		{lwasini}		{Add ABR}
* {23 Jan 2024}		{ggosal1}		{Add Material Delivered & Hang Time to Detail}
* {15 Apr 2024}		{lwasini}		{Change PopUp View to Table}
*******************************************************************/ 
CREATE PROCEDURE [dbo].[LoadAndHaulSP_AveragePayload_Get] 
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

		SELECT ROUND(AVG_Payload,0) [Actual],
			Target [ShiftTarget]
		FROM BAG.[CONOPS_BAG_OVERALL_AVG_PAYLOAD_V] WITH (NOLOCK)
		WHERE shiftflag = @SHIFT
 
		SELECT ap.ShovelID AS [Name],
			[dialog].Operator AS [OperatorName],
			[dialog].OperatorImageURL AS [ImageUrl],
			RIGHT('0000000000' + [dialog].[OperatorId], 10) OperatorId,
			ROUND(AVG_Payload,0) AS Actual,
			CAST([ap].Target AS DECIMAL(10)) AS [Target],
			[dialog].ReasonId AS ReasonIdx,
			[dialog].ReasonDesc AS Reason,
			ROUND([dialog].TotalMaterialMined / 1000,1) AS TotalMaterialMined,
			ROUND([dialog].TotalMaterialMinedTarget / 1000,1) AS TotalMaterialMinedTarget,
			ROUND([dialog].DeltaC,1) AS DeltaC,
			[dialog].DeltaCTarget,
			[dialog].IdleTime,
			[dialog].IdleTimeTarget,
			[dialog].Spotting,
			[dialog].SpottingTarget,
			[dialog].Loading,
			[dialog].LoadingTarget,
			[dialog].Dumping,
			[dialog].DumpingTarget,
			ROUND([dialog].NumberOfLoads,0) As NumberOfLoads,
			ROUND([dialog].NumberOfLoadsTarget,0) AS NumberOfLoadsTarget,
			ROUND([dialog].AssetEfficiency,0) AS AssetEfficiency,
			ROUND([dialog].AssetEfficiencyTarget,0) As AssetEfficiencyTarget,
			[dialog].TonsPerReadyHour AS TonsPerReadyHour,
			[dialog].TonsPerReadyHourTarget [TonsPerReadyHourTarget],
			ROUND([dialog].TotalMaterialMoved/1000.0,1) AS TotalMaterialMoved,
			ROUND([dialog].TotalMaterialMovedTarget/1000.0,1) AS TotalMaterialMovedTarget,
			ROUND([dialog].HangTime,2) AS HangTime,
			ROUND([dialog].HangTimeTarget,2) AS HangTimeTarget
			FROM BAG.[CONOPS_BAG_SP_AVG_PAYLOAD_V] [ap] WITH (NOLOCK)
		LEFT JOIN BAG.[CONOPS_BAG_SHOVEL_POPUP] [dialog] WITH (NOLOCK)
			ON [ap].shiftflag = [dialog].shiftflag
			AND [ap].ShovelID = [dialog].[ShovelID]
		WHERE [ap].shiftflag = @SHIFT
			AND ([ap].ShovelID IN (SELECT TRIM(value) FROM STRING_SPLIT(@EQMT, ',')) OR ISNULL(@EQMT, '') = '')
			AND ([dialog].eqmttype IN (SELECT TRIM(value) FROM STRING_SPLIT(@EQMTTYPE, ',')) OR ISNULL(@EQMTTYPE, '') = '')
			AND ([Status] IN (SELECT TRIM(value) FROM STRING_SPLIT(UPPER(@STATUS), ',')) OR ISNULL(@STATUS, '') = '');


		SELECT
		ROUND(AVG(Payload),0) Payload,
		TimeinHour
		FROM [BAG].[CONOPS_BAG_EQMT_SHOVEL_HOURLY_PAYLOAD_V] a
		LEFT JOIN [bag].[CONOPS_BAG_SHOVEL_INFO_V] b
		ON a.shiftflag = b.shiftflag AND a.equipment = b.shovelid
		WHERE 
		Equipment IS NOT NULL
		AND a.shiftflag = @SHIFT
		AND (Equipment IN (SELECT TRIM(value) FROM STRING_SPLIT(@EQMT, ',')) OR ISNULL(@EQMT, '') = '')
		AND (eqmttype IN (SELECT TRIM(value) FROM STRING_SPLIT(@EQMTTYPE, ',')) OR ISNULL(@E