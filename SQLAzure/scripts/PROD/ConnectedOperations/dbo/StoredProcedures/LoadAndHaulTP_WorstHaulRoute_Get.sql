

/******************************************************************  
* PROCEDURE	: dbo.LoadAndHaulTP_WorstHaulRoute_Get
* PURPOSE	: 
* NOTES		: 
* CREATED	: jrodulfa, 30 Nov 2022
* SAMPLE	: 
	1. EXEC dbo.LoadAndHaulTP_WorstHaulRoute_Get 'CURR', 'MOR', NULL, NULL, NULL
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {30 Nov 2022}		{jrodulfa}		{Initial Created} 
* {08 Dec 2022}		{jrodulfa}		{Combine to one table and Implement Eqmt and status filter in SP}  
* {12 Dec 2022}		{jrodulfa}		{Added Operator Image URL.} 
* {16 Dec 2022}		{sxavier}		{Rename field} 
* {09 Jan 2023}		{jrodulfa}		{Added Total Material Delivered data in Dialog message and simplified the query.} 
* {01 Sep 2023}		{lwasini}		{Add Paramter Equipment Type} 
* {28 Nov 2023}		{lwasini}		{Add OperatorId} 
* {10 Jan 2024}		{lwasini}		{Add TYR} 
* {19 Jan 2024}		{ggosal1}		{Add LoadedTravel, LoadedTravelTarget, EmptyTravel, EmptyTravelTarget}
* {23 Jan 2024}     {lwasini}		{Add ABR}
* {15 Apr 2024}		{lwasini}		{Change PopUp View to Table}
* {09 May 2025}		{ggosal1}		{Add Autonomous Filter}
* {07 Nov 2025}		{dbonardo}		{split string using udt}
*******************************************************************/ 
CREATE PROCEDURE [dbo].[LoadAndHaulTP_WorstHaulRoute_Get] 
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

	IF @SITE = 'BAG'
	BEGIN

		SELECT
			[worstHaul].TRUCK AS [Name],
			[dialog].Operator [OperatorName],
			[dialog].OperatorImageURL AS ImageUrl,
			[dialog].OperatorId,
			[dialog].ReasonId AS ReasonIdx,
			[dialog].ReasonDesc AS Reason,
			[worstHaul].SHOVEL AS Shovel,
			[worstHaul].DUMPNAME AS [Dump],
			ROUND(([dialog].[PayloadTarget] - [dialog].[Payload]),1) [OffTarget],
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
			[worstHaul].Location AS Destination
		FROM BAG.[CONOPS_BAG_WORST_HAUL_ROUTE_V] [worstHaul] 
		LEFT JOIN BAG.[CONOPS_BAG_TRUCK_POPUP] [dialog] WITH (NOLOCK)
			ON [worstHaul].shiftflag = [dialog].shiftflag
			AND [worstHaul].Truck = [dialog].TruckID
		LEFT JOIN  BAG.CONOPS_BAG_AUTONOMOUS_TRUCK_V d
			ON [worstHaul].TRUCK = d.TruckId 
		WHERE [worstHaul].shiftflag = @SHIFT
			AND ([worstHaul].TRUCK IN (SELECT [Value] FROM @splitEqmt) OR @EQMT IS NULL)
			AND ([dialog].eqmttype IN (SELECT [Value] FROM @splitEType) OR @EQMTTYPE IS NULL)
			AND ([worstHaul].[Status] IN (SELECT [Value] FROM @splitEStat) OR @STATUS IS NULL)
			AND (d.Autonomous = @AUTONOMOUS OR @AUTONOMOUS IS NULL)
		ORDE