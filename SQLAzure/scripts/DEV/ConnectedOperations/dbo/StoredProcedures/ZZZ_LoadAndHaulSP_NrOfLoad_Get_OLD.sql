


/******************************************************************  
* PROCEDURE	: dbo.LoadAndHaulSP_NrOfLoad_Get
* PURPOSE	: 
* NOTES		: 
* CREATED	: lwasini, 25 Oct 2022
* SAMPLE	: 
	1. EXEC dbo.LoadAndHaulSP_NrOfLoad_Get 'CURR', 'MOR',NULL,NULL
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {25 Oct 2022}		{lwasini}		{Initial Created} 
* {28 Dec 2022}		{sxavier}		{Rename field} 
*******************************************************************/ 
CREATE PROCEDURE [dbo].[LoadAndHaulSP_NrOfLoad_Get_OLD] 
(	
	@SHIFT VARCHAR(4),
	@SITE VARCHAR(4),
	@STATUS NVARCHAR(MAX),
	@EQMT NVARCHAR(MAX)
)
AS                        
BEGIN    
	 
	SELECT
		(SUM(shoveltarget) / 272.0) AS ShiftTarget,
		SUM(NrofLoad) AS Actual
	FROM 
		[dbo].[CONOPS_LH_SP_NROFLOAD_V_OLD]
	WHERE 
		shiftflag = @SHIFT
		AND siteflag = @SITE
		AND (excav IN (SELECT TRIM(value) FROM STRING_SPLIT(@EQMT, ',')) OR ISNULL(@EQMT, '') = '')
		AND (eqmtcurrstatus IN (SELECT TRIM(value) FROM STRING_SPLIT(UPPER(@STATUS), ',')) OR ISNULL(@STATUS, '') = '')
		;
	

	
	SELECT
		Excav AS [Name],
		NrofLoad AS Actual,
		ShovelNrofLoadTarget AS [Target],
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
		Efh,
		EfhTarget,
		Payload,
		272 AS PayloadTarget,
		AssetEfficiency,
		AssetEfficiencyTarget,
		TPRH/1000 AS TonsPerReadyHour,
		TPRHTarget/1000 AS TonsPerReadyHourTarget,
		ReasonIdx,
		reasons AS Reason
	FROM
		[dbo].[CONOPS_LH_SP_NROFLOAD_V_OLD]
	WHERE 
		shiftflag = @SHIFT
		AND siteflag = @SITE
		AND (excav IN (SELECT TRIM(value) FROM STRING_SPLIT(@EQMT, ',')) OR ISNULL(@EQMT, '') = '')
		AND (eqmtcurrstatus IN (SELECT TRIM(value) FROM STRING_SPLIT(UPPER(@STATUS), ',')) OR ISNULL(@STATUS, '') = '')
	ORDER BY NrofLoad DESC
		;



SET NOCOUNT OFF
END

