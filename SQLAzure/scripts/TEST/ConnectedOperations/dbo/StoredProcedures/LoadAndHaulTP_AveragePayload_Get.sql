
/******************************************************************  
* PROCEDURE	: dbo.LoadAndHaulTP_AveragePayload_Get
* PURPOSE	: 
* NOTES		: 
* CREATED	: jrodulfa, 01 DEC 2022
* SAMPLE	: 
	1. EXEC dbo.LoadAndHaulTP_AveragePayload_Get 'PREV', 'CVE', NULL, NULL, NULL, 1
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {01 Dec 2022}		{jrodulfa}		{Initial Created} 
* {02 Dec 2022}		{sxavier}		{Rename field and select only needed data} 
* {08 Dec 2022}		{jrodulfa}		{Implement Eqmt filter in SP}  
* {12 Dec 2022}		{jrodulfa}		{Added Operator Image URL.} 
* {21 Dec 2022}		{jrodulfa}		{Added data for Truck Detail Dialogbox.} 
* {09 Jan 2023}		{jrodulfa}		{Added Total Material Delivered data in Dialog message and simplified the query.} 
* {01 Sep 2023}		{lwasini}		{Add Parameter Equipment Type} 
* {18 Sep 2023}		{lwasini}		{Add Hourly Payload}
* {28 Nov 2023}		{lwasini}		{Add OperatorId} 
* {10 Jan 2024}		{lwasini}		{Add TYR} 
* {19 Jan 2024}		{ggosal1}		{Add LoadedTravel, LoadedTravelTarget, EmptyTravel, EmptyTravelTarget}
* {23 Jan 2024}		{lwasini}		{Add ABR}
* {15 Apr 2024}		{lwasini}		{Change PopUp View to Table}
* {08 May 2025}		{ggosal1}		{Add Autonomous Filter}
* {07 Nov 2025}		{dbonardo}		{split string using udt}
*******************************************************************/ 
CREATE PROCEDURE [dbo].[LoadAndHaulTP_AveragePayload_Get] 
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
			ROUND(AVG(p.MEASURETON),0) AS Actual,
			AVG(PayloadTarget) AS [ShiftTarget]
		FROM BAG.CONOPS_BAG_PAYLOAD_MEASURETON_V p
		LEFT JOIN BAG.CONOPS_BAG_TRUCK_DETAIL_V e
			ON p.SHIFTID = e.SHIFTID
			AND p.TRUCK = e.TruckId
		LEFT JOIN  BAG.CONOPS_BAG_AUTONOMOUS_TRUCK_V d
			ON p.TRUCK = d.TruckId 
		WHERE e.shiftflag = @SHIFT
			AND (p.TRUCK IN (SELECT [Value] FROM @splitEqmt) OR @EQMT IS NULL)
			AND (e.statusname IN (SELECT [Value] FROM @splitEStat) OR @STATUS IS NULL)
			AND (e.eqmttype IN (SELECT [Value] FROM @splitEType) OR @EQMTTYPE IS NULL)
			AND (d.Autonomous = @AUTONOMOUS OR @AUTONOMOUS IS NULL);

		SELECT
			[pl].TRUCK AS [Name],
			[dialog].Operator AS [OperatorName],
			[dialog].OperatorImageURL AS [ImageURL],
			[dialog].OperatorId,
			ROUND([pl].AVG_Payload,0) AS Actual,
			CAST([pl].Target AS DECIMAL(10)) AS [Target],
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
			ROUND([dialog].AvgUseOfAvailibilityTarget,0) AS AvgUseOfAvailibilityT