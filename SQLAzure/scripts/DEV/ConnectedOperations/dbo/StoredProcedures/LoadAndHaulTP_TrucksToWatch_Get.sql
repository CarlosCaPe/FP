


/******************************************************************  
* PROCEDURE	: dbo.LoadAndHaulTP_TrucksToWatch_Get
* PURPOSE	: 
* NOTES		: 
* CREATED	: jrodulfa, 14 DEC 2022
* SAMPLE	: 
	1. EXEC dbo.LoadAndHaulTP_TrucksToWatch_Get 'CURR', 'MOR', NULL, NULL, NULL, 0
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {14 Dec 2022}		{jrodulfa}		{Initial Created} 
* {09 Jan 2023}		{jrodulfa}		{Added Total Material Delivered data in Dialog message and simplified the query.} 
* {11 Jan 2023}		{jrodulfa}		{Implement Bagdad data and simplified the query.} 
* {17 May 2023}		{lwasini}		{Exclude Truck in Ready status} 
* {01 Sep 2023}		{lwasini}		{Add Parameter Equipment Type} 
* {08 Sep 2023}		{lwasini}		{Add TotalMaterialMined & TotalMaterialMoved}
* {28 Nov 2023}		{lwasini}		{Add OperatoirId}
* {10 Jan 2024}		{lwasini}		{Add TYR} 
* {19 Jan 2024}		{ggosal1}		{Add LoadedTravel, LoadedTravelTarget, EmptyTravel, EmptyTravelTarget}
* {23 Jan 2024}     {lwasini}		{Add ABR}
* {15 Apr 2024}		{lwasini}		{Change PopUp View to Table}
* {04 Sep 2024}		{ggosal1}		{Change BAG: TempTable}
* {09 May 2025}		{ggosal1}		{Add Autonomous Filter}
*******************************************************************/ 
CREATE PROCEDURE [dbo].[LoadAndHaulTP_TrucksToWatch_Get] 
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
		DECLARE @TableTempBAG TABLE(
			shiftflag VARCHAR (5),
			siteflag VARCHAR (5),
			TruckID VARCHAR (10),
			OperatorId VARCHAR (20),
			Location VARCHAR (50),
			StatusName VARCHAR (30),
			ShiftDuration INT,
			availability_pct DECIMAL (10,3),
			[TPRH] DECIMAL (10,3),
			TotalMaterialMined INT,
			TotalMaterialMoved INT,
			TotalMaterialMinedTarget INT
		)

		INSERT INTO @TableTempBAG
		SELECT shiftflag,
			   siteflag,
			   TruckID,
			   OperatorId,
			   Location,
			   StatusName,
			   ShiftDuration,
			   availability_pct,
			   [TPRH],
			   TotalMaterialMined,
			   TotalMaterialMoved,
			   TotalMaterialMinedTarget
		FROM [bag].[CONOPS_BAG_TRUCK_TO_WATCH_V];

		SELECT TOP 25 PERCENT
			[tw].TruckID AS [Name],
			[dialog].Operator AS OperatorName,
			[dialog].OperatorImageURL AS ImageUrl,
			[dialog].OperatorId,
			[dialog].ReasonId AS ReasonIdx,
			[dialog].ReasonDesc AS Reason,
			COALESCE([tw].[TPRH], 0) AS Tprh,
			ROUND([dialog].[Payload],0) AS AvgPayload,
			ROUND(([dialog].[PayloadTarget] - [dialog].[Payload]),1) [OffTarget],
			ROUND([dialog].[Payload],0) AS Payload,
			[dialog].[PayloadTarget],
			ROUND([tw].TotalMaterialMined,1) TotalMaterialMined,
			ROUND([tw].TotalMaterialMoved,1) TotalMaterialMoved,
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
			ROUND([dialog].AvgUseOfAvailibilityTarget,0) As AvgUseOfAvailibilityTarget,
			[tw].Location AS Destination
		FROM @TableTempBAG [tw]
		LEFT JOIN BAG.[CONOPS_BAG_TRUCK_POPUP] [dialog] WITH (NOLOCK)
			ON [tw].shiftflag = [dialog].shiftflag
			AND [tw].TruckID = [dialog].TruckID
		WHERE [tw].shiftflag = @SHIFT