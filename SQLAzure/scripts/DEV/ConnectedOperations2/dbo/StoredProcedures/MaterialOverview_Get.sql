




/******************************************************************  
* PROCEDURE	: dbo.MaterialOverview_Get
* PURPOSE	: 
* NOTES		: 
* CREATED	: lwasini, 25 Oct 2022
* SAMPLE	: 
	1. EXEC dbo.MaterialOverview_Get 'CURR', 'MOR'
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {15 Feb 2023}		{lwasini}		{Initial Created}  
* {15 Feb 2023}		{sxavier}		{Rename field.}  
* {01 Mar 2024}		{lwasini}		{Display 0 for Other Site} 
*******************************************************************/ 
CREATE PROCEDURE [dbo].[MaterialOverview_Get] 
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
		0 TotalMaterialMined,
		0 ShiftTargetTotalMaterialMined,
		0 TargetTotalMaterialMined,
		0 TotalMaterialMoved,
		0 ShiftTargetTotalMaterialMoved,
		0 TargetTotalMaterialMoved,
		0 CrushLeach,
		0 TargetCrushLeach,
		0 ShiftTargetCrushLeach,
		0 MillOre,
		0 TargetMillOre,
		0 ShiftTargetMillOre,
		0 RomLeach,
		0 TargetRomLeach,
		0 ShiftTargetRomLeach
	END

	ELSE IF @SITE = 'MOR'
	BEGIN
		SELECT 
		ROUND(TotalMaterialMined/1000,1) AS TotalMaterialMined,
		ROUND(TotalMaterialMinedShiftTarget/1000,1) AS ShiftTargetTotalMaterialMined,
		ROUND(TotalMaterialMinedTarget/1000,1) AS TargetTotalMaterialMined,
		ROUND(TotalMaterialMoved/1000,1) AS TotalMaterialMoved,
		ROUND(TotalMaterialMovedShiftTarget/1000,1) AS ShiftTargetTotalMaterialMoved,
		ROUND(TotalMaterialMovedTarget/1000,1) AS TargetTotalMaterialMoved,
		ROUND(CrushedLeachMined/1000,1) AS CrushLeach,
		ROUND(CrushedLeachTarget/1000,1) AS TargetCrushLeach,
		ROUND(CrushedLeachShiftTarget/1000,1) AS ShiftTargetCrushLeach,
		ROUND(MillOreMined/1000,1) AS MillOre,
		ROUND(MillOreTarget/1000,1) AS TargetMillOre,
		ROUND(MillOreShiftTarget/1000,1) AS ShiftTargetMillOre,
		ROUND(ROMLeachMined/1000 ,1) AS RomLeach,
		ROUND(ROMLeachTarget/1000,1) AS TargetRomLeach,
		ROUND(ROMLeachShiftTarget/1000,1) AS ShiftTargetRomLeach
		FROM [MOR].[EWS_MOR_MATERIAL_OVERVIEW_V] (NOLOCK)
		WHERE 
		shiftflag = @SHIFT
	END 


	ELSE IF @SITE = 'BAG'
	BEGIN
		SELECT 
		ROUND(TotalMaterialMined/1000,1) AS TotalMaterialMined,
		ROUND(TotalMaterialMinedShiftTarget/1000,1) AS ShiftTargetTotalMaterialMined,
		ROUND(TotalMaterialMinedTarget/1000,1) AS TargetTotalMaterialMined,
		ROUND(TotalMaterialMoved/1000,1) AS TotalMaterialMoved,
		ROUND(TotalMaterialMovedShiftTarget/1000,1) AS ShiftTargetTotalMaterialMoved,
		ROUND(TotalMaterialMovedTarget/1000,1) AS TargetTotalMaterialMoved,
		ROUND(CrushedLeachMined/1000,1) AS CrushLeach,
		ROUND(CrushedLeachTarget/1000,1) AS TargetCrushLeach,
		ROUND(CrushedLeachShiftTarget/1000,1) AS ShiftTargetCrushLeach,
		ROUND(MillOreMined/1000,1) AS MillOre,
		ROUND(MillOreTarget/1000,1) AS TargetMillOre,
		ROUND(MillOreShiftTarget/1000,1) AS ShiftTargetMillOre,
		ROUND(ROMLeachMined/1000 ,1) AS RomLeach,
		ROUND(ROMLeachTarget/1000,1) AS TargetRomLeach,
		ROUND(ROMLeachShiftTarget/1000,1) AS ShiftTargetRomLeach
		FROM [BAG].[EWS_BAG_MATERIAL_OVERVIEW_V] (NOLOCK)
		WHERE 
		shiftflag = @SHIFT
	END 


	ELSE IF @SITE = 'CMX'
	BEGIN
		SELECT 
		ROUND(TotalMaterialMined/1000,1) AS TotalMaterialMined,
		ROUND(TotalMaterialMinedShiftTarget/1000,1) AS ShiftTargetTotalMaterialMined,
		ROUND(TotalMaterialMinedTarget/1000,1) AS TargetTotalMaterialMined,
		ROUND(TotalMaterialMoved/1000,1) AS TotalMaterialMoved,
		ROUND(TotalMaterialMovedShiftTarget/1000,1) AS ShiftTargetTotalMaterialMoved,
		ROUND(TotalMaterialMovedTarget/1000,1) AS TargetTotalMaterialMoved,
		ROUND(CrushedLeachMined/1000,1) AS CrushLeach,
		ROUND(CrushedLeachTarget/1000,1) AS TargetCrushLeach,
		ROUND(CrushedLeachShiftTarget/1000,1) AS ShiftTargetCrushLeach,
		ROUND(MillOreMined/1000,1) AS MillOre,
		ROUND(MillOreTarget/1000