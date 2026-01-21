

/******************************************************************  
* PROCEDURE	: dbo.LoadAndHaulOverview_TotalMaterialMined_Get
* PURPOSE	: 
* NOTES		: 
* CREATED	: lwasini, 25 Oct 2022
* SAMPLE	: 
	1. EXEC dbo.LoadAndHaulOverview_TotalMaterialMined_Get 'PREV', 'SAF'
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {25 Oct 2022}		{lwasini}		{Initial Created}  
* {22 Nov 2022}		{sxavier}		{Add field Waste, TargetWaste, and ShiftTargetWaste}
* {26 Jan 2023}		{jrodulfa}		{Implement Safford data.}
* {27 Jan 2023}		{jrodulfa}		{Change SAF sitecode to SAM.}
* {06 Feb 2023}		{jrodulfa}		{Implement Chino Data.}
* {10 Feb 2023}		{jrodulfa}		{Implement Cerro Verde Data.}
*******************************************************************/ 
CREATE PROCEDURE [dbo].[LoadAndHaulOverview_TotalMaterialMined_Get_NEW] 
(	
	@SHIFT VARCHAR(4),
	@SITE VARCHAR(4)
)
AS                        
BEGIN          

	DECLARE @SHCEMA VARCHAR(4);

	SET @SITE = CASE @SITE
					WHEN 'SAM' THEN 'SAF'
					WHEN 'CVE' THEN 'CER'
					WHEN 'CHN' THEN 'CHI'
					ELSE @SITE
				END;
	
	SET @SHCEMA = CASE @SITE
					WHEN 'CMX' THEN 'CLI'
					ELSE @SITE
				END;
EXEC (
' SELECT '
+' ROUND(CrushedLeachActual/1000.0,1) AS CrushLeach,'
+' ROUND(CrushedLeachTarget/1000.0,1) AS TargetCrushLeach,'
+' ROUND(CrushedLeachShiftTarget/1000.0,1) AS ShiftTargetCrushLeach,'
+' ROUND(MillOreActual/1000.0,1) AS MillOre,'
+' ROUND(MillOreTarget/1000.0 ,1) AS TargetMillOre,'
+' ROUND(MillOreShiftTarget/1000.0 ,1) AS ShiftTargetMillOre,'
+' ROUND(ROMLeachActual/1000.0 ,1) AS RomLeach,'
+' ROUND(ROMLeachTarget/1000.0 ,1) AS TargetRomLeach,'
+' ROUND(ROMLeachShiftTarget/1000.0 ,1) AS ShiftTargetRomLeach,'
+' ROUND(WasteActual/1000.0 ,1) AS Waste,'
+' ROUND(WasteTarget/1000.0 ,1) AS TargetWaste,'
+' ROUND(WasteShiftTarget/1000.0 ,1) AS ShiftTargetWaste'
+' FROM '+@SHCEMA+'.[CONOPS_'+@SHCEMA+'_TOTAL_MATERIAL_MINE_V] (NOLOCK)'
+' WHERE '
+' shiftflag = '''+@SHIFT+''''
+' AND siteflag = '''+@SITE+''';'

	

);

END

