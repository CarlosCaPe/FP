

/******************************************************************  
* PROCEDURE	: dbo.LoadAndHaulSP_NrOfLoad_Get
* PURPOSE	: 
* NOTES		: 
* CREATED	: lwasini, 25 Oct 2022
* SAMPLE	: 
	1. EXEC dbo.LoadAndHaulSP_NrOfLoad_Get 'PREV', 'SAM',NULL,NULL,NULL
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {25 Oct 2022}		{lwasini}		{Initial Created} 
* {28 Dec 2022}		{sxavier}		{Rename field} 
* {31 Aug 2023}		{lwasini}		{Add Parameter Equipment Type} 
* {18 Sep 2023}		{lwasini}		{Add Hourly #Load} 
* {28 Nov 2023}		{lwasini}		{Add OperatorId}
* {10 jan 2024}		{lwasini}		{Add TYR}
* {23 Jan 2024}		{lwasini}		{Add ABR}
* {23 Jan 2024}		{ggosal1}		{Add Material Delivered & Hang Time to Detail} 
* {10 Nov 2025}		{dbonardo}		{Split String Using udt}
*******************************************************************/ 
CREATE PROCEDURE [dbo].[LoadAndHaulSP_NrOfLoad_Get] 
(	
	@SHIFT VARCHAR(4),
	@SITE VARCHAR(4),
	@STATUS NVARCHAR(MAX),
	@EQMT NVARCHAR(MAX),
	@EQMTTYPE NVARCHAR(MAX)
)
AS                        
BEGIN    

	DECLARE @splitEqmt [dbo].[udTT_SplitValue];
	DECLARE @splitEStat [dbo].[udTT_SplitValue];
	DECLARE @splitEType [dbo].[udTT_SplitValue];

	INSERT INTO @splitEqmt ([Value])
	SELECT TRIM([value]) FROM STRING_SPLIT(@EQMT, ',');

	INSERT INTO @splitEStat ([Value])
	SELECT TRIM([value]) FROM STRING_SPLIT(@STATUS, ',');

	INSERT INTO @splitEType ([Value])
	SELECT TRIM([value]) FROM STRING_SPLIT(@EQMTTYPE, ',');

BEGIN TRY

	IF @SITE = 'BAG'
	BEGIN

		SELECT
			ROUND(SUM(NumberOfLoadsTarget),0) AS ShiftTarget,
			ROUND(SUM(NumberOfLoads),0) AS Actual
			FROM BAG.[CONOPS_BAG_SP_NROFLOAD_V]
		WHERE 
		shiftflag = @SHIFT
			AND (ShovelID IN (SELECT [Value] FROM @splitEqmt) OR @EQMT IS NULL)
			AND (eqmttype IN (SELECT [Value] FROM @splitEType) OR @EQMTTYPE IS NULL)
			AND (eqmtcurrstatus IN (SELECT [Value] FROM @splitEStat) OR @STATUS IS NULL);
 
		SELECT
			ShovelID AS [Name],
			ROUND(NumberOfLoads,0) AS Actual,
			ROUND(NumberOfLoadsTarget,0) AS [Target],
			Operator AS OperatorName,
			OperatorImageURL as ImageUrl,
			RIGHT('0000000000' + [OperatorId], 10) OperatorId,
			ROUND(TotalMaterialMined/1000.0,1) AS TotalMaterialMined,
			ROUND(TotalMaterialMinedTarget/1000.0,1) AS TotalMaterialMinedTarget,
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
			ROUND(Payload,0) AS Payload,
			PayloadTarget,
			ROUND(AssetEfficiency,0) AS AssetEfficiency,
			ROUND(AssetEfficiencyTarget,0) AS AssetEfficiencyTarget,
			TonsPerReadyHour AS TonsPerReadyHour,
			TonsPerReadyHourTarget AS TonsPerReadyHourTarget,
			ROUND(TotalMaterialMoved/1000.0,1) AS TotalMaterialMoved,
			ROUND(TotalMaterialMovedTarget/1000.0,1) AS TotalMaterialMovedTarget,
			ROUND(HangTime,2) AS HangTime,
			ROUND(HangTimeTarget,2) AS HangTimeTarget,
			ReasonIdx,
			reasons AS Reason
		FROM BAG.[CONOPS_BAG_SP_NROFLOAD_V]
		WHERE shiftflag = @SHIFT
			AND (ShovelID IN (SELECT [Value] FROM @splitEqmt) OR @EQMT IS NULL)
			AND (eqmttype IN (SELECT [Value] FROM @splitEType) OR @EQMTTYPE IS NULL)
			AND (eqmtcurrstatus IN (SELECT [Value] FROM @splitEStat) OR @STATUS IS NULL)
		ORDER BY NumberOfLoads DESC;

		SELECT
		SUM(NofLoad) AS NumberofLoads,
		TimeinHour
		FROM [BAG].[CONOPS_BAG_EQMT_HOURLY_NOFLOAD_V] a
		LEFT JOIN [bag].[CONOPS_BAG_SHOVEL_INFO_V] b
		ON a.shiftflag = b.shiftflag AND a.equipment = b.shovelid
		WHERE 
		Equipment IS NOT NULL
		AND a.shiftflag = @SHIFT
		AND (Equipment IN (SELECT [Value] FROM @splitEqmt) OR @EQMT IS NULL)
		AND (eqmttype IN (SELECT [Value] FROM @splitEType) OR @EQMTTYPE IS NULL)
		AND (StatusName IN (SELECT [Value] FROM @splitEStat) OR @STATUS IS NULL)
		GROUP BY TimeinHour
		ORDER BY TimeinHour DESC;

	END

	ELSE IF @SITE = 'CVE'
	BEG