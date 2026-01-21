
/******************************************************************  
* PROCEDURE	: dbo.LoadAndHaulTP_TruckStatusEquipmentDetail_Get
* PURPOSE	: 
* NOTES		: 
* CREATED	: lwasini, 25 Oct 2022
* SAMPLE	: 
	1. EXEC dbo.LoadAndHaulTP_TruckStatusEquipmentDetail_Get 'CURR', 'CVE', NULL , NULL, NULL, 0
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {25 Oct 2022}		{lwasini}		{Initial Created}
* {28 Nov 2023}		{lwasini}		{Add OperatorId}
* {10 Jan 2024}		{lwasini}		{Add TYR} 
* {19 Jan 2024}		{ggosal1}		{Add LoadedTravel, LoadedTravelTarget, EmptyTravel, EmptyTravelTarget}
* {23 Jan 2024}     {lwasini}		{Add ABR}
*******************************************************************/ 
CREATE PROCEDURE [dbo].[LoadAndHaulTP_TruckStatusEquipmentDetail_Get] 
(	
	@SHIFT VARCHAR(4),
	@SITE VARCHAR(4),
	@STATUS NVARCHAR(MAX),
	@EQMT NVARCHAR(MAX),
	@EQMTTYPE NVARCHAR(MAX),
	@AUTONOMOUS INT
)
AS                        
BEGIN 

	DECLARE @splitEqmt [dbo].[udTT_SplitValue];
	DECLARE @splitEStat [dbo].[udTT_SplitValue];
	DECLARE @splitEType [dbo].[udTT_SplitValue];

	INSERT INTO @splitEqmt ([Value])
	SELECT TRIM([value]) FROM STRING_SPLIT(@EQMT, ',');

	INSERT INTO @splitEStat ([Value])
	SELECT TRIM([value]) FROM STRING_SPLIT(@STATUS, ',');

	INSERT INTO @splitEType ([Value])
	SELECT TRIM([value]) FROM STRING_SPLIT(@EQMTTYPE, ',');

BEGIN TRY

	IF @SITE = 'BAG'
	BEGIN

		SELECT 
			truck AS [Name],
			toper AS OperatorName,
			OperatorImageURL as ImageUrl,
			OperatorId,
			ROUND(TotalMaterialDelivered,1) AS TotalMaterialDelivered,
			ROUND(TotalMaterialDeliveredTarget,1) AS TotalMaterialDeliveredTarget,
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
			LoadedTravel,
			LoadedTravelTarget,
			EmptyTravel,
			EmptyTravelTarget,
			ROUND(useOfAvailability,0) AS AvgUseOfAvailibility,
			ROUND(useOfAvailabilityTarget,0) AS AvgUseOfAvailibilityTarget,
			[destination],
			reasonidx AS ReasonIdx,
			reasons AS Reason,
			eqmtcurrstatus,
			Autonomous
		FROM BAG.[CONOPS_BAG_TP_DELTA_C_V] a
		LEFT JOIN BAG.CONOPS_BAG_AUTONOMOUS_TRUCK_V b
			ON a.Truck = b.TruckId
		WHERE shiftflag = @SHIFT
			AND (a.truck IN (SELECT [Value] FROM @splitEqmt) OR @EQMT IS NULL)
			AND (eqmtcurrstatus IN (SELECT [Value] FROM @splitEStat) OR @STATUS IS NULL)
			AND (a.EQMTTYPE IN (SELECT [Value] FROM @splitEType) OR @EQMTTYPE IS NULL)
			AND (b.Autonomous = @AUTONOMOUS OR @AUTONOMOUS IS NULL)

	END

	ELSE IF @SITE = 'CVE'
	BEGIN

		SELECT 
			truck AS [Name],
			toper AS OperatorName,
			OperatorImageURL as ImageUrl,
			OperatorId,
			ROUND(TotalMaterialDelivered,1) AS TotalMaterialDelivered,
			ROUND(TotalMaterialDeliveredTarget,1) AS TotalMaterialDeliveredTarget,
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
			dumpingAtCrusherTarget 