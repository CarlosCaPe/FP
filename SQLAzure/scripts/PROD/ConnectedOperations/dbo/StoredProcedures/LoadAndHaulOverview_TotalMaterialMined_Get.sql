



/******************************************************************  
* PROCEDURE	: dbo.LoadAndHaulOverview_TotalMaterialMined_Get
* PURPOSE	: 
* NOTES		: 
* CREATED	: lwasini, 25 Oct 2022
* SAMPLE	: 
	1. EXEC dbo.LoadAndHaulOverview_TotalMaterialMined_Get 'PREV', 'MOR'
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {25 Oct 2022}		{lwasini}		{Initial Created}  
* {22 Nov 2022}		{sxavier}		{Add field Waste, TargetWaste, and ShiftTargetWaste}
* {26 Jan 2023}		{jrodulfa}		{Implement Safford data.}
* {27 Jan 2023}		{jrodulfa}		{Change SAF sitecode to SAM.}
* {06 Feb 2023}		{jrodulfa}		{Implement Chino Data.}
* {10 Feb 2023}		{jrodulfa}		{Implement Cerro Verde Data.}
* {30 Aug 2023}		{ggosal1}		{Add Total Material Mined Total}
* {10 jan 2024}		{lwasini}		{Add TYR}
* {23 Jan 2024}		{lwasini}		{Add ABR} 
* {28 Feb 2025}		{ggosal1}		{Show Total Material Mined as Tons, not kt} 
*******************************************************************/ 
CREATE PROCEDURE [dbo].[LoadAndHaulOverview_TotalMaterialMined_Get] 
(	
	@SHIFT VARCHAR(4),
	@SITE VARCHAR(4)
)
AS                        
BEGIN          

BEGIN TRY

	IF @SITE = 'BAG'
	BEGIN

		SELECT
			SHIFTFLAG,
			ROUND(CrushedLeachActual/1000.0,1) AS CrushLeach,
			ROUND(CrushedLeachTarget/1000.0,1) AS TargetCrushLeach,
			ROUND(CrushedLeachShiftTarget/1000.0,1) AS ShiftTargetCrushLeach,
			ROUND(MillOreActual/1000.0,1) AS MillOre,
			ROUND(MillOreTarget/1000.0 ,1) AS TargetMillOre,
			ROUND(MillOreShiftTarget/1000.0 ,1) AS ShiftTargetMillOre,
			ROUND(ROMLeachActual/1000.0 ,1) AS RomLeach,
			ROUND(ROMLeachTarget/1000.0 ,1) AS TargetRomLeach,
			ROUND(ROMLeachShiftTarget/1000.0 ,1) AS ShiftTargetRomLeach,
			ROUND(WasteActual/1000.0 ,1) AS Waste,
			ROUND(WasteTarget/1000.0 ,1) AS TargetWaste,
			ROUND(WasteShiftTarget/1000.0 ,1) AS ShiftTargetWaste,
			ROUND(TotalMaterialMined ,1) AS TotalMaterialMined
			FROM BAG.[CONOPS_BAG_TOTAL_MATERIAL_MINE_V] (NOLOCK)
		WHERE shiftflag = @SHIFT

	END

	ELSE IF @SITE = 'CVE'
	BEGIN

		SELECT
			ROUND(CrushedLeachActual/1000.0,1) AS CrushLeach,
			ROUND(CrushedLeachTarget/1000.0,1) AS TargetCrushLeach,
			ROUND(CrushedLeachShiftTarget/1000.0,1) AS ShiftTargetCrushLeach,
			ROUND(MillOreActual/1000.0,1) AS MillOre,
			ROUND(MillOreTarget/1000.0 ,1) AS TargetMillOre,
			ROUND(MillOreShiftTarget/1000.0 ,1) AS ShiftTargetMillOre,
			ROUND(ROMLeachActual/1000.0 ,1) AS RomLeach,
			ROUND(ROMLeachTarget/1000.0 ,1) AS TargetRomLeach,
			ROUND(ROMLeachShiftTarget/1000.0 ,1) AS ShiftTargetRomLeach,
			ROUND(WasteActual/1000.0 ,1) AS Waste,
			ROUND(WasteTarget/1000.0 ,1) AS TargetWaste,
			ROUND(WasteShiftTarget/1000.0 ,1) AS ShiftTargetWaste,
			ROUND(TotalMaterialMined ,1) AS TotalMaterialMined
			FROM CER.[CONOPS_CER_TOTAL_MATERIAL_MINE_V] (NOLOCK)
		WHERE shiftflag = @SHIFT

	END

	ELSE IF @SITE = 'CHN'
	BEGIN

		SELECT
			ROUND(CrushedLeachActual/1000.0,1) AS CrushLeach,
			ROUND(CrushedLeachTarget/1000.0,1) AS TargetCrushLeach,
			ROUND(CrushedLeachShiftTarget/1000.0,1) AS ShiftTargetCrushLeach,
			ROUND(MillOreActual/1000.0,1) AS MillOre,
			ROUND(MillOreTarget/1000.0 ,1) AS TargetMillOre,
			ROUND(MillOreShiftTarget/1000.0 ,1) AS ShiftTargetMillOre,
			ROUND(ROMLeachActual/1000.0 ,1) AS RomLeach,
			ROUND(ROMLeachTarget/1000.0 ,1) AS TargetRomLeach,
			ROUND(ROMLeachShiftTarget/1000.0 ,1) AS ShiftTargetRomLeach,
			ROUND(WasteActual/1000.0 ,1) AS Waste,
			ROUND(WasteTarget/1000.0 ,1) AS TargetWaste,
			ROUND(WasteShiftTarget/1000.0 ,1) AS ShiftTargetWaste,
			ROUND(TotalMaterialMined ,1) AS TotalMaterialMined
			FROM CHI.[CONOPS_CHI_TOTAL_MATERIAL_MINE_V] (NOLOCK)
		WHERE shiftflag = @SHIFT

	END

	ELSE IF @SITE = 'CMX'
	BEGIN

		SELECT
			ROUND(CrushedLeachActual/1000.0,1) AS CrushLeach,
			ROUND(CrushedLeachTarget/1000.0,1) AS TargetCrushLeach,
			ROUND(CrushedLeachShi