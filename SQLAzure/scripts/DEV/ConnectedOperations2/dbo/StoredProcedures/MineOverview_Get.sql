
/******************************************************************  
* PROCEDURE	: dbo.MineOverview_Get
* PURPOSE	: 
* NOTES		: 
* CREATED	: lwasini, 25 Oct 2022
* SAMPLE	: 
	1. EXEC dbo.MineOverview_Get 'CURR', 'SIE'
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {15 Feb 2023}		{lwasini}		{Initial Created}  
* {15 Feb 2023}		{sxavier}		{Rename field.}  
* {11 Sep 2023}		{ggosal1}		{Update EFH Column Name} 
* {01 Mar 2024}		{lwasini}		{Display 0 for Other Site} 
* {06 Jan 2025}		{ggosal1}		{Handling OSS Site ID} 
* {07 Jan 2025}		{ggosal1}		{Change EFH to ShiftEFH} 
*******************************************************************/ 
CREATE PROCEDURE [dbo].[MineOverview_Get] 
(	
	@SHIFT VARCHAR(4),
	@SITE VARCHAR(4)
)
AS
BEGIN

SET @SITE = dbo.GetSiteOssID(@SITE)

BEGIN TRY

	IF @SITE NOT IN ('BAG','CVE','CHN','CMX','MOR','SAM','SIE')
	BEGIN
		SELECT 
		NULL [Name],
		0 [Actual],
		0 ShiftTarget,
		0 [Target];


		--Material Mined
		SELECT 
		0 Actual,
		0 [Target];

		--Mine Productivity
		SELECT 
		0 Actual,
		0 [Target];


		--Delta C
		SELECT 
		0 Actual,
		0 [Target];


		--Equivalen Flat Haul
		SELECT 
		0 Actual,
		0 [Target];
	END


	ELSE IF @SITE = 'MOR'
	BEGIN
		SELECT 
		[Name],
		ROUND((sum(LeachActual) + sum(MillOreActual)),0) AS [Actual],
		ROUND((sum(LeachShiftTarget) + sum(MillOreShiftTarget)),0) AS ShiftTarget,
		ROUND((sum(LeachTarget) + sum(MillOreTarget)),0) AS [Target]
		FROM [MOR].[CONOPS_MOR_MATERIAL_DELIVERED_TO_CHRUSHER_V] 
		WHERE shiftflag = @SHIFT
		GROUP BY [Name];


		--Material Mined
		SELECT 
		ROUND(TotalMaterialMined/1000.0,2) AS Actual,
		ROUND(TotalMaterialMinedShiftTarget/1000,2) AS [Target]
		FROM [MOR].[EWS_MOR_MATERIAL_OVERVIEW_V]
		WHERE
		shiftflag = @SHIFT;

		--Mine Productivity
		SELECT 
		ROUND(mineproductivity/1000,2) AS Actual,
		ROUND([target]/1000,2) AS [Target]
		FROM [MOR].[CONOPS_MOR_MINE_PRODUCTIVITY_V]
		WHERE
		shiftflag = @SHIFT;


		--Delta C
		SELECT 
		ROUND(delta_c,1) AS Actual,
		ROUND(DeltaCtarget,1) AS [Target]
		FROM [MOR].[CONOPS_MOR_OVERALL_DELTA_C_V]
		WHERE
		shiftflag = @SHIFT;


		--Equivalen Flat Haul
		SELECT TOP 1
		ROUND(ShiftEFH,0) AS Actual,
		ROUND(EFHShiftTarget,0) AS [Target]
		FROM [MOR].[CONOPS_MOR_EFH_V] 
		WHERE
		shiftflag = @SHIFT;
		
	END

	ELSE IF @SITE = 'BAG'
	BEGIN
		SELECT 
		[Name],
		ROUND((sum(LeachActual) + sum(MillOreActual)),0) AS [Actual],
		ROUND((sum(LeachShiftTarget) + sum(MillOreShiftTarget)),0) AS ShiftTarget,
		ROUND((sum(LeachTarget) + sum(MillOreTarget)),0) AS [Target]
		FROM [BAG].[CONOPS_BAG_MATERIAL_DELIVERED_TO_CHRUSHER_V] 
		WHERE shiftflag = @SHIFT
		GROUP BY [Name];


		--Material Mined
		SELECT 
		ROUND(TotalMaterialMined/1000.0,2) AS Actual,
		ROUND(TotalMaterialMinedShiftTarget/1000,2) AS [Target]
		FROM [BAG].[EWS_BAG_MATERIAL_OVERVIEW_V]
		WHERE
		shiftflag = @SHIFT;

		--Mine Productivity
		SELECT 
		ROUND(mineproductivity/1000,2) AS Actual,
		ROUND([target]/1000,2) AS [Target]
		FROM [BAG].[CONOPS_BAG_MINE_PRODUCTIVITY_V]
		WHERE
		shiftflag = @SHIFT;


		--Delta C
		SELECT 
		ROUND(delta_c,1) AS Actual,
		ROUND(DeltaCtarget,1) AS [Target]
		FROM [BAG].[CONOPS_BAG_OVERALL_DELTA_C_V]
		WHERE
		shiftflag = @SHIFT;


		--Equivalen Flat Haul
		SELECT TOP 1
		ROUND(ShiftEFH,0) AS Actual,
		ROUND(EFHShiftTarget,0) AS [Target]
		FROM [BAG].[CONOPS_BAG_EFH_V] 
		WHERE
		shiftflag = @SHIFT;
		
	END


	ELSE IF @SITE = 'CMX'
	BEGIN
		SELECT 
		[Name],
		ROUND((sum(LeachActual) + sum(MillOreActual)),0) AS [Actual],
		ROUND((sum(LeachShiftTarget) + sum(MillOreShiftTarget)),0) AS ShiftTarget,
		ROUND((sum(LeachTarget) + sum(MillOreTarget)),0) AS [Target]
		FROM [CLI].[CONOPS_CLI_MATERIAL_DELIVERED_TO_CHRUSHER_V] 
		WHERE shiftflag = @SHIFT
		GROUP BY [Name];


		--Material Mined
	