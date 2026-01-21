

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
CREATE PROCEDURE [dbo].[LoadAndHaulOverview_TotalMaterialMined_Get_OLD] 
(	
	@SHIFT VARCHAR(4),
	@SITE VARCHAR(4)
)
AS                        
BEGIN          

	SET @SITE = CASE @SITE
					WHEN 'SAM' THEN 'SAF'
					WHEN 'CVE' THEN 'CER'
					WHEN 'CHN' THEN 'CHI'
					ELSE @SITE
				END;
	
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
		ROUND(WasteShiftTarget/1000.0 ,1) AS ShiftTargetWaste
	FROM 
		[dbo].[CONOPS_LH_TOTAL_MATERIAL_MINED_V] (NOLOCK)
	WHERE 
		shiftflag = @SHIFT
		AND siteflag = @SITE;

	--SELECT 
	--	ShovelId, 
	--	operatorname AS OperatorName,
	--	OperatorImageURL,
	--	--concat('https://images.services.fmi.com/publishedimages/',operatorid,'.jpg') as ImageUrl,
	--	shovelactual/1000 as Actual,
	--	shoveltarget/1000 as [Target],
	--	Offtarget/1000 as OffTarget,
	--	delta_c AS DeltaC,
	--	deltac_target AS DeltaCTarget,
	--	idletime AS IdleTime,
	--	idletimeTarget AS IdleTimeTarget,
	--	spotting AS Spotting,
	--	SpotingTarget AS SpottingTarget,
	--	loading AS Loading,
	--	LoadingTarget AS LoadingTarget,
	--	dumping AS Dumping,
	--	dumpingtarget AS DumpingTarget,
	--	EFH AS Efh,
	--	EFHTarget AS EfhTarget,
	--	reasonidx AS ReasonIdx,
	--	reasons As Reason
	--FROM 
	--	[dbo].[CONOPS_LH_SHOVEL_TO_WATCH_V] (NOLOCK)
	--WHERE 
	--	shiftflag = @SHIFT
	--	AND siteflag = @SITE
	--ORDER BY Actual ASC;

	--SELECT 
	--	COUNT(ShovelId) as ShovelsToWatch
	--FROM 
	--	[dbo].[CONOPS_LH_SHOVEL_TO_WATCH_V] (NOLOCK)
	--where 
	--	shiftflag = @SHIFT
	--	AND siteflag = @SITE;

	

SET NOCOUNT OFF
END

