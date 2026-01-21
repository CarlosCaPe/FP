

/******************************************************************  
* PROCEDURE	: dbo.LoadAndHaulTP_DeltaC_Get
* PURPOSE	: 
* NOTES		: 
* CREATED	: lwasini, 25 Oct 2022
* SAMPLE	: 
	1. EXEC dbo.LoadAndHaulTP_DeltaC_Get 'CURR', 'CVE', NULL,NULL
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {25 Oct 2022}		{lwasini}		{Initial Created}
* {7 Dec 2022}		{sxavier}		{Rename field}
* {20 Jan 2022}		{jrodulfa}		{Implement SAF data}
* {27 Jan 2023}		{jrodulfa}		{Change SAF sitecode to SAM.}
* {01 Feb 2022}		{mbote}		    {Implement Cerro Verde data}
* {02 Deb 2023}		{jrodulfa}		{Implement Chino Data.} 
*******************************************************************/ 
CREATE PROCEDURE [dbo].[LoadAndHaulTP_DeltaC_Get_OLD] 
(	
	@SHIFT VARCHAR(4),
	@SITE VARCHAR(4),
	@STATUS NVARCHAR(MAX),
	@EQMT NVARCHAR(MAX)
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
	 ROUND(avg(a.Actual),1) as Actual,
	 a.ShiftTarget
	 FROM (
	SELECT 
		AVG(deltac) AS Actual,
		Delta_c_target AS ShiftTarget
	FROM 
		[dbo].[CONOPS_LH_TP_DELTA_C_V]
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
		OperatorImageURL as ImageUrl,
		ROUND(TotalMaterialDelivered/1000,1) AS TotalMaterialDelivered, 
		ROUND(TotalMaterialDeliveredTarget/1000,1) AS TotalMaterialDeliveredTarget, 
		ROUND(AVG_Payload,0) AS Payload,
		AVG_PayloadTarget AS PayloadTarget,
		ROUND(DeltaC,1) AS DeltaC,
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
		DumpingAtStockpile AS [DumpsAtStockpile],
		dumpingatStockpileTarget AS DumpsAtStockpileTarget,
		DumpingAtCrusher As DumpsAtCrusher,
		dumpingAtCrusherTarget AS DumpsAtCrusherTarget,
		ROUND(useOfAvailability,0) AS useOfAvailability,
		ROUND(useOfAvailabilityTarget,0) AS AvgUseOfAvailibilityTarget,
		[destination],
		Pit,
		reasonidx AS ReasonIdx,
		reasons AS Reason
	FROM 
		[dbo].[CONOPS_LH_TP_DELTA_C_V]
	WHERE 
		shiftflag = @SHIFT
		AND siteflag = @SITE
		AND (truck IN (SELECT TRIM(value) FROM STRING_SPLIT(@EQMT, ',')) OR ISNULL(@EQMT, '') = '')
		AND (eqmtcurrstatus IN (SELECT TRIM(value) FROM STRING_SPLIT(UPPER(@STATUS), ',')) OR ISNULL(@STATUS, '') = '')

	ORDER BY deltac DESC;

	
	


SET NOCOUNT OFF
END

