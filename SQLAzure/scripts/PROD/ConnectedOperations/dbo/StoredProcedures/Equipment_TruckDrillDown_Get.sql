

/******************************************************************  
* PROCEDURE	: dbo.Equipment_TruckDrillDown_Get
* PURPOSE	: 
* NOTES		: 
* CREATED	: mbote, 27 Feb 2023
* SAMPLE	: 
	1. EXEC dbo.Equipment_TruckDrillDown_Get 'PREV', 'MOR'
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {15 Mar 2023}		{mbote}		{Initial Created}}
* {02 May 2023}		{sxavier}	{Rename Hr to TimeinHour}
* {20 Oct 2023}		{lwasini}	{Add TonsMoved & Availability}
* {12 Jan 2024}		{lwasini}	{Add TYR}
* {23 Jan 2024}     {lwasini}	{Add ABR}
* {19 Sep 2024}     {ggosal1}	{Add DeltaC Details}
* {25 Sep 2024}     {ggosal1}	{Rename dumpname to DumpName}
*******************************************************************/ 
CREATE PROCEDURE [dbo].[Equipment_TruckDrillDown_Get] 
(	
	@SHIFT VARCHAR(4),
	@SITE VARCHAR(4)
	--@EQMT NVARCHAR(MAX)
)
AS                        
BEGIN   

BEGIN TRY

	IF @SITE = 'BAG'
	BEGIN

		SELECT 
			[TruckID]
			,[Operator]
			,[OperatorImageURL]
			,[ReasonId]
			,Comment
			,[Location]
			,ROUND(TimeinState,2) [TimeInState]
			,Crew
			,[AssignedShovel]
			,ROUND([Payload],0) [Payload]
			,[PayloadTarget]
			,ROUND([IdleTime],1) [IdleTime]
			,[IdleTimeTarget]
			,ROUND([DeltaC],1) [DeltaC]
			,[DeltaCTarget]
			,NumberofDumps
			,NumberofDumpsTarget
			,ROUND([DumpsAtStockpile],1) [DumpsAtStockpile]
			,[DumpsAtStockpileTarget]
			,ROUND(EFH,0) [EquivalentFlatHaul]
			,efhTarget AS EquivalentFlatHaulTarget
			,ROUND([Loading],1) [Loading]
			,[LoadingTarget]
			,ROUND([Spotting],1) [Spotting]
			,[SpottingTarget]
			,ROUND([DumpsAtCrusher],1) [DumpsAtCrusher]
			,[DumpsAtCrusherTarget]
			,[TotalMaterialDelivered]
			,[TotalMaterialDeliveredTarget]
			,ROUND(LoadedTravel,1) [LoadedTravel]
			,[LoadedTravelTarget]
			,ROUND([EmptyTravel],1) [EmptyTravel]
			,[EmptyTravelTarget]
			,ROUND(UseofAvailability,0) [UseofAvailability]
			,[UseofAvailabilityTarget]
			,ROUND([Availability],0) [Availability]
			,AvailabilityTarget
			,TonsMoved
			,TonsMovedTarget
		FROM [bag].[CONOPS_BAG_EQMT_TRUCK_V]
		WHERE shiftflag = @SHIFT;

		SELECT
			Equipment,
			ROUND(Payload,0) [Payload],
			TimeinHour
		FROM [bag].[CONOPS_BAG_EQMT_TRUCK_HOURLY_PAYLOAD_V]
		WHERE shiftflag =  @SHIFT;

		SELECT
			Equipment,
			ROUND(IdleTime,1) [IdleTime],
			ROUND(DeltaC,1) [DeltaC],
			ROUND(Spotting,1) [Spotting],
			ROUND(Loading,1) [Loading],
			ROUND(DumpingAtStockpile,1) [DumpsAtStockpile],
			ROUND(DumpingAtCrusher,1) [DumpsAtCrusher],
			ROUND(LoadedTravel,1) [LoadedTravel],
			ROUND(EmptyTravel,1) [EmptyTravel],
			ROUND(EFH,0) [EquivalentFlatHaul],
			deltac_ts AS TimeinHour
		FROM [bag].[CONOPS_BAG_EQMT_TRUCK_HOURLY_DELTAC_V]
		WHERE shiftflag =  @SHIFT;

		SELECT 
			[Equipment]
			,[Hr] AS TimeinHour
			,ROUND([UofA],0) [UseofAvailability]
			,ROUND([Avail],0) [Availability]
		FROM [bag].[CONOPS_BAG_HOURLY_TRUCK_ASSET_EFFICIENCY_V] WITH (NOLOCK)
		WHERE shiftflag =  @SHIFT
		AND [EqmtUnit] = 1;
		
		
		SELECT 
			[Equipment]
			,TotalMaterialDelivered
			,TimeinHour
		FROM [bag].[CONOPS_BAG_EQMT_TRUCK_HOURLY_TOTALMATERIALDELIVERED_V]
		WHERE shiftflag =  @SHIFT;

		
		SELECT 
			[Equipment]
			,NumberofDumps
			,TimeinHour
		FROM [bag].[CONOPS_BAG_EQMT_TRUCK_HOURLY_NRDUMP_V]
		WHERE shiftflag =  @SHIFT;
		
		SELECT
		TruckID AS Equipment,
		SUM(TotalMaterialMoved) AS TonsMoved,
		TimeinHour
		FROM [bag].[CONOPS_BAG_EQMT_SHOVEL_HOURLY_TOTALMATERIALMINED_V] a
		LEFT JOIN [bag].[CONOPS_BAG_TRUCK_DETAIL_V] b
		ON a.shiftflag = b.shiftflag AND a.Equipment = b.assignedshovel
		WHERE a.shiftflag = @SHIFT
		AND TruckID IS NOT NULL
		GROUP BY TruckID,TimeinHour
		ORDER BY TruckID,TimeinHour ASC;

		SELECT
			dc.eqmt AS Equipment,
			dc.DumpName,
			dc.LoadCount,
			dc.MOE_TotalCycle,
			dc.MOE_Loaded,
			dc.MOE_Empty,
			dc.MOE_Dumping,
			dc.