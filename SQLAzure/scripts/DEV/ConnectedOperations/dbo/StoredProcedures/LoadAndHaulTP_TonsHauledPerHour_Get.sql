

/******************************************************************  
* PROCEDURE	: dbo.LoadAndHaulTP_TonsHauledPerHour_Get
* PURPOSE	: 
* NOTES		: 
* CREATED	: jrodulfa, 13 Dec 2022
* SAMPLE	: 
	1. EXEC dbo.LoadAndHaulTP_TonsHauledPerHour_Get 'CURR', 'CVE', NULL, NULL, NULL
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {13 Dec 2022}		{jrodulfa}		{Initial Created} 
* {16 Dec 2022}		{sxavier}		{Rename field} 
* {21 Dec 2022}		{jrodulfa}		{Added data for Truck Detail Dialogbox.} 
* {22 Dec 2022}		{sxavier}		{Rename field} 
* {01 Feb 2023}		{jrodulfa}		{Change average to sum for aggregated data in TPH.}
* {01 Sep 2023}		{lwasini}		{Add Parameter Equipment Type} 
* {28 Nov 2023}		{lwasini}		{Add OperatorId} 
* {10 Jan 2024}		{lwasini}		{Add TYR} 
* {19 Jan 2024}		{ggosal1}		{Add LoadedTravel, LoadedTravelTarget, EmptyTravel, EmptyTravelTarget}
* {23 Jan 2024}     {lwasini}		{Add ABR}
* {15 Apr 2024}		{lwasini}		{Change PopUp View to Table}
* {08 May 2025}		{ggosal1}		{Add Autonomous Filter}
*******************************************************************/ 
CREATE PROCEDURE [dbo].[LoadAndHaulTP_TonsHauledPerHour_Get] 
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
			ROUND(SUM([tph]),0) [Actual]
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
			ROUND([tprh].[tph],0) [Actual],
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
			AND (UPPER([dialog].StatusName) IN (SELECT TRIM(value) FROM STRING_SPLIT(UPPER(@STATUS), ',')) OR ISNUL