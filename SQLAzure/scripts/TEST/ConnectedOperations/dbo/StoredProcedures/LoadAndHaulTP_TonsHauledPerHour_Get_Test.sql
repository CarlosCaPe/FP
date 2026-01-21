
/******************************************************************  
* PROCEDURE   : LoadAndHaulTP_TonsHauledPerHour_Get_Test
* PURPOSE     : Copy of dbo.LoadAndHaulTP_TonsHauledPerHour_Get for testing
* NOTES       : Identical logic; only the procedure name differs
* CREATED     : 29 Sep 2025
* SAMPLE      : 
    1. EXEC dbo.CrushAndConvey_Throughput_Get_Test 'CURR', 'TYR'
*******************************************************************/ 
CREATE PROCEDURE [dbo].[LoadAndHaulTP_TonsHauledPerHour_Get_Test] 
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

BEGIN TRY

	IF @SITE = 'BAG'
	BEGIN

		SELECT
			ROUND(SUM([tph]),0) + 111 AS [Actual]
		FROM BAG.[CONOPS_BAG_TP_TONS_HAUL_V] [tprh] WITH (NOLOCK)
		LEFT JOIN BAG.[CONOPS_BAG_TRUCK_DETAIL_V] [t] WITH (NOLOCK)
			ON [tprh].Truck = [t].TruckID
			AND [tprh].shiftflag = [t].shiftflag
		WHERE [tprh].shiftflag = @SHIFT
			AND ([Truck] IN (SELECT TRIM(value) FROM STRING_SPLIT(@EQMT, ',')) OR ISNULL(@EQMT, '') = '') 
			AND (eqmttype IN (SELECT TRIM(value) FROM STRING_SPLIT(@EQMTTYPE, ',')) OR ISNULL(@EQMTTYPE, '') = '') 
			AND (UPPER([t].StatusName) IN (SELECT TRIM(value) FROM STRING_SPLIT(UPPER(@STATUS), ',')) OR ISNULL(@STATUS, '') = '')
			AND (Truck IN (SELECT TruckID FROM BAG.CONOPS_BAG_AUTONOMOUS_TRUCK_V WHERE Autonomous = @AUTONOMOUS) OR ISNULL(@AUTONOMOUS, '') = '');
 
		SELECT [tprh].Truck AS [Name],
			ROUND([tprh].[tph],0) + 111 AS [Actual],
			[dialog].Operator AS OperatorName,
			[dialog].OperatorImageURL AS ImageUrl,
			[dialog].OperatorId,
			[dialog].ReasonId AS ReasonIdx,
			[dialog].ReasonDesc AS Reason,
			ROUND([dialog].[Payload],0) AS Payload,
			[dialog].[PayloadTarget],
			ROUND([dialog].[TotalMaterialDelivered],1) AS [TotalMaterialDelivered],
			ROUND([dialog].[TotalMaterialDeliveredTarget],1) AS [TotalMaterialDeliveredTarget],
			ROUND([dialog].DeltaC,1) AS DeltaC,
			[dialog].DeltaCTarget,
			[dialog].IdleTime,
			[dialog].IdleTimeTarget,
			[dialog].Spotting,
			[dialog].SpottingTarget,
			[dialog].Loading,
			[dialog].LoadingTarget,
			[dialog].Dumping,
			[dialog].DumpingTarget,
			[dialog].Efh,
			[dialog].EfhTarget,
			[dialog].[DumpsAtStockpile],
			[dialog].DumpsAtStockpileTarget,
			[dialog].DumpsAtCrusher,
			[dialog].DumpsAtCrusherTarget,
			[dialog].LoadedTravel,
			[dialog].LoadedTravelTarget,
			[dialog].EmptyTravel,
			[dialog].EmptyTravelTarget,
			ROUND([dialog].AvgUseOfAvailibility,0) AS AvgUseOfAvailibility,
			ROUND([dialog].AvgUseOfAvailibilityTarget,0) AS AvgUseOfAvailibilityTarget,
			[dialog].Location AS Destination
		FROM BAG.[CONOPS_BAG_TP_TONS_HAUL_V] [tprh]
		LEFT JOIN BAG.[CONOPS_BAG_TRUCK_POPUP] [dialog] WITH (NOLOCK)
			ON [tprh].shiftflag = [dialog].shiftflag
			AND [tprh].Truck = [dialog].TruckID
		WHERE [tprh].shiftflag = @SHIFT
			AND ([tprh].[Truck] IN (SELECT TRIM(value) FROM STRING_SPLIT(@EQMT, ',')) OR ISNULL(@EQMT, '') = '') 
			AND (eqmttype IN (SELECT TRIM(value) FROM STRING_SPLIT(@EQMTTYPE, ',')) OR ISNULL(@EQMTTYPE, '') = '') 
			AND (UPPER([dialog].StatusName) IN (SELECT TRIM(value) FROM STRING_SPLIT(UPPER(@STATUS), ',')) OR ISNULL(@STATUS, '') = '')
			AND ([tprh].Truck IN (SELECT TruckID FROM BAG.CONOPS_BAG_AUTONOMOUS_TRUCK_V WHERE Autonomous = @AUTONOMOUS) OR ISNULL(@AUTONOMOUS, '') = '')

	END

	ELSE IF @SITE = 'CVE'
	BEGIN

		SELECT
			ROUND(SUM([tph]),0) + 111 AS [Actual]
		FROM CER.[CONOPS_CER_TP_TONS_HAUL_V] [tprh] WITH (NOLOCK)
		LEFT JOIN CER.[CONOPS_CER_TRUCK_DETAIL_V] [t] WITH (NOLOCK)
			ON [tprh].Truck = [t].TruckID
			AND [tprh].shiftflag = [t].shiftflag
		WHERE [tprh].shiftflag = @SHIFT
			AND ([Truck] IN (SELECT TRIM(value) FROM STRING_SPLIT(@EQMT, ',')) OR ISNULL(@EQMT, '') = '') 
			AND (eqmttype IN (SELECT TRIM(value) FROM STRING_SPLIT(@EQMTTYPE, ',')) OR ISNULL(@EQMTTYP