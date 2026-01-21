






/******************************************************************  
* PROCEDURE	: dbo.LoadAndHaulSP_TotalMaterialMined_Get
* PURPOSE	: 
* NOTES		: 
* CREATED	: lwasini, 25 Oct 2022
* SAMPLE	: 
	1. EXEC dbo.LoadAndHaulSP_TotalMaterialMined_Get 'CURR', 'MOR',NULL,NULL
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {25 Oct 2022}		{lwasini}		{Initial Created}  
* {13 Dec 2022}		{sxavier}		{Rename field and comment count ShovelToWatch} 
*******************************************************************/ 
CREATE PROCEDURE [dbo].[LoadAndHaulSP_TotalMaterialMined_Get_OLD] 
(	
	@SHIFT VARCHAR(4),
	@SITE VARCHAR(4),
	@STATUS NVARCHAR(MAX),
	@EQMT NVARCHAR(MAX)
)
AS                        
BEGIN          

	SELECT 
		ShovelId AS [Name], 
		operatorname AS OperatorName,
		concat('https://images.services.fmi.com/publishedimages/',operatorid,'.jpg') as ImageUrl,
		shovelactual/1000 as TotalMaterialMined,
		shoveltarget/1000 as TotalMaterialMinedTarget,
		Offtarget/1000 as OffTarget,
		delta_c AS DeltaC,
		deltac_target AS DeltaCTarget,
		idletime AS IdleTime,
		idletimeTarget AS IdleTimeTarget,
		spotting AS Spotting,
		SpotingTarget AS SpottingTarget,
		loading AS Loading,
		LoadingTarget AS LoadingTarget,
		dumping AS Dumping,
		dumpingtarget AS DumpingTarget,
		reasonidx AS ReasonIdx,
		reasons As Reason,
		TPRH/1000 AS TonsPerReadyHour,
		TPRHTarget/1000 AS TonsPerReadyHourTarget,
		NrofLoad AS NumberOfLoads,
		NrofLoadTarget AS NumberOfLoadsTarget,
		AssetEfficiency,
		AssetEfficiencyTarget,
		Payload,
		PayloadTarget
	FROM 
		[dbo].[CONOPS_LH_SP_TOTAL_MATERIAL_MINED_V_OLD] (NOLOCK)
	WHERE 
		shiftflag = @SHIFT
		AND siteflag = @SITE
		AND (shovelid IN (SELECT TRIM(value) FROM STRING_SPLIT(@EQMT, ',')) OR ISNULL(@EQMT, '') = '')
		AND (eqmtcurrstatus IN (SELECT TRIM(value) FROM STRING_SPLIT(UPPER(@STATUS), ',')) OR ISNULL(@STATUS, '') = '')
	ORDER BY TotalMaterialMined ASC;

	--SELECT 
	--	COUNT(ShovelId) as ShovelsToWatch
	--FROM 
	--	[dbo].[CONOPS_LH_SP_TOTAL_MATERIAL_MINED_V] (NOLOCK)
	--where 
	--	shiftflag = @SHIFT
	--	AND siteflag = @SITE
	--	AND (shovelid IN (SELECT TRIM(value) FROM STRING_SPLIT(@EQMT, ',')) OR ISNULL(@EQMT, '') = '')
	--	AND (eqmtcurrstatus IN (SELECT TRIM(value) FROM STRING_SPLIT(UPPER(@STATUS), ',')) OR ISNULL(@STATUS, '') = '')
	--	;

	

SET NOCOUNT OFF
END

