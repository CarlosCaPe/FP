CREATE VIEW [BAG].[CONOPS_BAG_TP_DELTA_C_V] AS

--select * FROm [bag].[CONOPS_BAG_TP_DELTA_C_V] where shiftflag = 'curr'
CREATE VIEW [bag].[CONOPS_BAG_TP_DELTA_C_V]
AS 

WITH DELTAC AS (
	SELECT shiftindex
		,site_code
		,truck
		,deltac
		,idletime
		,spottime
		,loadtime
		,DumpingTime
		,EFH
		,DumpingAtStockpile
		,DumpingAtCrusher
		,LoadedTravel
		,EmptyTravel
	FROM [bag].[CONOPS_BAG_TP_DELTA_C_AVG_V]
),

STAT AS (
	SELECT shiftid
		,eqmt
		,reasonidx
		,reasons
		,[status] AS eqmtcurrstatus
		,ROW_NUMBER() OVER (PARTITION BY shiftid,eqmt ORDER BY startdatetime DESC) num
	FROM [bag].[asset_efficiency](NOLOCK)
	WHERE unittype = 'truck'
),

PIT AS (
	SELECT
		SHIFT_ID AS ShiftId,
		SITE_CODE,
		TRUCK_NAME AS Truck,
		CASE WHEN SOURCEBLOCKLEVEL IS NULL THEN 'Other' 
			ELSE LEFT(SOURCEBLOCKLEVEL, 2) END AS Pushback,
		DUMPINGENDTIME_LOCAL_TS,
		ROW_NUMBER() OVER (PARTITION BY SHIFT_ID,TRUCK_NAME ORDER BY DUMPINGENDTIME_LOCAL_TS DESC) row_num
	FROM bag.fleet_truck_cycle_v
)

SELECT pop.shiftflag
	,pop.siteflag
	,pop.shiftid
	,dc.truck
	,pop.eqmttype
	,UPPER(pop.operator) AS toper
	,pop.OperatorImageURL
	,pop.OperatorID
	,pop.payload AS AVG_Payload
	,pop.payloadtarget AS AVG_PayloadTarget
	,dc.deltac
	,pop.DeltaCTarget AS Delta_c_target
	,dc.idletime
	,pop.idletimetarget
	,dc.spottime
	,pop.SpottingTarget AS spottarget
	,dc.loadtime
	,pop.LoadingTarget AS loadtarget
	,dc.DumpingTime
	,pop.dumpingtarget
	,dc.EFH
	,pop.EFHtarget
	,dc.DumpingAtStockpile
	,pop.DumpsAtStockpileTarget AS dumpingatStockpileTarget
	,dc.DumpingAtCrusher
	,pop.DumpsAtCrusherTarget AS dumpingAtCrusherTarget
	,dc.LoadedTravel
	,pop.LoadedTravelTarget
	,dc.EmptyTravel
	,pop.EmptyTravelTarget
	,pop.AvgUseOfAvailibility AS useOfAvailability
	,pop.AvgUseOfAvailibilityTarget AS useOfAvailabilityTarget
	,pop.TotalMaterialDelivered
	,pop.TotalMaterialDeliveredTarget
	,pop.[Location] AS [destination]
	,pit.Pushback AS Pit
	,stat.reasonidx
	,stat.reasons
	,stat.eqmtcurrstatus
FROM DELTAC dc
INNER JOIN [bag].[CONOPS_BAG_TRUCK_POPUP] pop WITH (NOLOCK) ON dc.shiftindex = pop.shiftindex
	AND dc.truck = pop.TruckID
LEFT JOIN STAT stat ON pop.shiftid = stat.shiftid
	AND stat.eqmt = dc.truck
	AND stat.num = 1
LEFT JOIN PIT pit ON pit.ShiftId = pop.ShiftId
	AND pit.TRUCK = dc.truck
	AND pit.row_num = 1

