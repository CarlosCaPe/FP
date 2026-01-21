





/******************************************************************  
* PROCEDURE	: dbo.LoadAndHaulTP_DeltaC_Get
* PURPOSE	: 
* NOTES		: 
* CREATED	: lwasini, 25 Oct 2022
* SAMPLE	: 
	1. EXEC dbo.TP_TEST 'CURR', 'MOR',NULL,NULL
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {25 Oct 2022}		{lwasini}		{Initial Created}
* {7 Dec 2022}		{sxavier}		{Rename field}
*******************************************************************/ 
CREATE PROCEDURE [dbo].[TP_TEST] 
(	
	@SHIFT VARCHAR(4),
	@SITE VARCHAR(4),
	@STATUS NVARCHAR(MAX),
	@EQMT NVARCHAR(MAX)
)
AS                        
BEGIN    
	 
	 SELECT avg(a.Actual) as Actual,a.ShiftTarget
	 FROM (
	SELECT 
		AVG(deltac) AS Actual,
		Delta_c_target AS ShiftTarget
	FROM 
		[dbo].[CONOPS_LH_TP_DELTA_C_V_NEW]
	WHERE 
		shiftflag = @SHIFT
		AND siteflag = @SITE
		AND (truck IN (SELECT TRIM(value) FROM STRING_SPLIT(@EQMT, ',')) OR ISNULL(@EQMT, '') = '')
		AND (eqmtcurrstatus IN (SELECT TRIM(value) FROM STRING_SPLIT(UPPER(@STATUS), ',')) OR ISNULL(@STATUS, '') = '')

	GROUP BY shiftflag,siteflag,shiftid,Delta_c_target,truck,eqmtcurrstatus) a
	GROUP BY a.ShiftTarget;


	SELECT TOP 15 
		truck AS [Name],
		toper AS OperatorName,
		--concat('https://images.services.fmi.com/publishedimages/',operatorid,'.jpg') as ImageUrl,
		Actual AS TotalMaterialMined,
		[Target] AS TotalMaterialMinedTarget,
		DeltaC,
		Delta_c_target AS DeltaCTarget,
		idletime AS IdleTime,
		idletimetarget AS IdleTimeTarget,
		spottime AS Spotting,
		spottarget AS SpottingTarget,
		loadtime AS Loading,
		loadtarget AS LoadingTarget,
		DumpingTime AS Dumping,
		dumpingtarget AS DumpingTarget,
		EFH AS Efh,
		EFHtarget AS EfhTarget,
		reasonidx AS ReasonIdx,
		reasons AS Reason
	FROM 
		[dbo].[CONOPS_LH_TP_DELTA_C_V_NEW]
	WHERE 
		shiftflag = @SHIFT
		AND siteflag = @SITE
		AND (truck IN (SELECT TRIM(value) FROM STRING_SPLIT(@EQMT, ',')) OR ISNULL(@EQMT, '') = '')
		AND (eqmtcurrstatus IN (SELECT TRIM(value) FROM STRING_SPLIT(UPPER(@STATUS), ',')) OR ISNULL(@STATUS, '') = '')

	ORDER BY deltac DESC;

	
	


SET NOCOUNT OFF
END

