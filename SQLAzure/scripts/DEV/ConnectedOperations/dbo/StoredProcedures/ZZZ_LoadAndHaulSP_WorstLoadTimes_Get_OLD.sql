


/******************************************************************  
* PROCEDURE	: dbo.LoadAndHaulSP_WorstLoadTimes_Get
* PURPOSE	: 
* NOTES		: 
* CREATED	: lwasini, 25 Oct 2022
* SAMPLE	: 
	1. EXEC dbo.LoadAndHaulSP_WorstLoadTimes_Get 'PREV', 'MOR',NULL,NULL
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {25 Oct 2022}		{lwasini}		{Initial Created} 
* {29 Dec 2022}		{sxavier}		{Rename field and remove unused quey} 
*******************************************************************/ 
CREATE PROCEDURE [dbo].[LoadAndHaulSP_WorstLoadTimes_Get_OLD] 
(	
	@SHIFT VARCHAR(4),
	@SITE VARCHAR(4),
	@STATUS NVARCHAR(MAX),
	@EQMT NVARCHAR(MAX)
)
AS                        
BEGIN    
	 
	SELECT
		Excav AS [Name],
		LoadTime AS DataActual,
		--LoadTimeTarget,
		OperatorName,
		concat('https://images.services.fmi.com/publishedimages/',operatorid,'.jpg') as ImageUrl,
		shovelactual AS TotalMaterialMined,
		shoveltarget AS TotalMaterialMinedTarget,
		delta_c AS DeltaC,
		deltac_target AS DeltaCTarget,
		IdleTime,
		IdleTimeTarget,
		Spotting,
		SpotingTarget AS SpottingTarget,
		Loading,
		LoadingTarget,
		Dumping,
		DumpingTarget,
		NrofLoad AS NumberOfLoads,
		ShovelNrofLoadTarget AS NumberOfLoadsTarget,
		TPRH/1000 AS TonsPerReadyHour,
		TPRHTarget/1000 AS TonsPerReadyHourTarget,
		AssetEfficiency,
		AssetEfficiencyTarget, 
		Payload,
		272 AS PayloadTarget,
		ReasonIdx,
		reasons AS Reason
	FROM
		[dbo].[CONOPS_LH_SP_WORST_LOAD_TIME_V_OLD]
	WHERE 
		shiftflag = @SHIFT
		AND siteflag = @SITE
		AND (excav IN (SELECT TRIM(value) FROM STRING_SPLIT(@EQMT, ',')) OR ISNULL(@EQMT, '') = '')
		AND (eqmtcurrstatus IN (SELECT TRIM(value) FROM STRING_SPLIT(UPPER(@STATUS), ',')) OR ISNULL(@STATUS, '') = '')
	ORDER BY LoadTime DESC
		;



SET NOCOUNT OFF
END

