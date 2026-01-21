

/******************************************************************  
* PROCEDURE	: dbo.LoadAndHaulTP_TruckDownNotInShop_Get
* PURPOSE	: 
* NOTES		: 
* CREATED	: jrodulfa, 01 Dec 2022
* SAMPLE	: 
	1. EXEC dbo.LoadAndHaulTP_TruckDownNotInShop_Get 'PREV', 'SAM', NULL, NULL, NULL
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {01 Dec 2022}		{jrodulfa}		{Initial Created} 
* {08 Dec 2022}		{sxavier}		{Combine to one table} 
* {08 Dec 2022}		{jrodulfa}		{Implement Eqmt filter in SP and Added Truck Detail Dialog.}
* {12 Dec 2022}		{jrodulfa}		{Added Reason ID, Reason Desc and Operator Image URL.}
* {20 Dec 2022}		{jrodulfa}		{Remove Eqmt filter in SP as requested by Brian.}
* {09 Jan 2023}		{jrodulfa}		{Added Total Material Delivered data in Dialog message and simplified the query.} 
* {18 Sep 2023}		{lwasini}		{Add Paramter EQMT,EQMTTYPE,STATUS}
* {18 Sep 2023}		{ggosal1}		{Add Availability}
* {28 Nov 2023}		{lwasini}		{Add OperatorId}
* {10 Jan 2024}		{lwasini}		{Add TYR} 
* {19 Jan 2024}		{ggosal1}		{Add LoadedTravel, LoadedTravelTarget, EmptyTravel, EmptyTravelTarget}
* {23 Jan 2024}     {lwasini}		{Add ABR}
* {15 Apr 2024}		{lwasini}		{Change PopUp View to Table}
* {08 May 2025}		{ggosal1}		{Add Autonomous Filter}
*******************************************************************/ 
CREATE PROCEDURE [dbo].[LoadAndHaulTP_TruckDownNotInShop_Get] 
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
			[truckDown].TruckID AS [Name],
			ROUND(([dialog].[PayloadTarget] - [dialog].[Payload]),1) [OffTarget],
			[dialog].Operator AS [OperatorName],
			[dialog].OperatorImageURL AS ImageUrl,
			[dialog].OperatorId,
			CONVERT(VARCHAR(5), StatusStart, 108) AS [Time],
			[dialog].ReasonId AS ReasonIdx,
			[dialog].ReasonDesc AS Reason,
			Region,
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
			ROUND([dialog].Availability,0) AS Availability,
			ROUND([dialog].AvailabilityTarget,0) AS AvailabilityTarget,
			[truckDown].Location AS Destination
		FROM BAG.[CONOPS_BAG_TRUCK_DOWN_NOT_IN_SHOP_V] [truckDown]
		LEFT JOIN BAG.[CONOPS_BAG_TRUCK_POPUP] [dialog] WITH (NOLOCK)
			ON [truckDown].shiftflag = [dialog].shiftflag
			AND [truckDown].TruckID = [dialog].TruckID
		WHERE [truckDown].shiftflag = @SHIFT
			AND [truckDown].TruckID IS NOT NULL
			AND ([truckDown].TruckID IN (SELECT TRIM(value) FROM STRING_SPLIT(@EQMT, ',')) OR ISNULL(@EQMT, '') = '')
			AND ([dialog].[eqmttype] IN (SELECT TRIM(value) FROM STRING_SPLIT(@EQMTTYPE, ',')) OR ISNULL(@EQMTTYPE, '') = '')
			AND ([dialog].[StatusName] IN (SELECT TRIM(value) FROM STRING_SPLIT(UPPER(@STATUS), ',')) OR ISNULL(@STATUS, '') = '')
			AND ([truckDown].TruckID  IN (SELECT TruckID FROM BAG.CONOPS_BAG_AUTONOMOUS_TRUCK_V WHERE Autonomous = @AUTONOMOUS) OR ISNULL(@AUTONOMOUS, '') = '')

	END

	ELSE IF @SITE = 'CVE'
	