CREATE VIEW [MOR].[CONOPS_MOR_TP_DELTA_C_V] AS

--select  shiftflag,siteflag,truck,deltac from [mor].[CONOPS_MOR_TP_DELTA_C_V] where shiftflag = 'prev' and truck = 'T622'
CREATE VIEW [mor].[CONOPS_MOR_TP_DELTA_C_V]
AS
 
WITH DELTAC AS ( 
SELECT
	shiftindex,
	truck,
	deltac,
	idletime,
	spottime,
	loadtime,
	DumpingTime,
	EFH,
	DumpingAtStockpile,
	DumpingAtCrusher,
	LoadedTravel,
	EmptyTravel 
FROM [mor].[CONOPS_MOR_TP_DELTA_C_AVG_V]
),
 
PIT AS ( 
SELECT  
	SiteFlag,
	ShiftId,
	truck,
	case when LOC like '%WT%' THEN 'W COOPER 10' 
	when LOC like '%WF%' THEN 'W COOPER 14' 
	when LOC like '%SR%' THEN 'SUN RIDGE MINE' 
	when LOC like '%AM%' THEN 'AMT MINE' 
	when LOC like '%WC%' THEN 'W COOPER' 
	when LOC like '%CO%' THEN 'CORONADO' 
	when LOC IS NULL THEN 'Other' 
	when LOC like '%MIL%' THEN 'Mill Stockpiles' 
	ELSE LOC end as Pushback,
	ROW_NUMBER() OVER (PARTITION BY ShiftId, Truck ORDER BY TimeEmpty_TS DESC) row_num 
FROM MOR.SHIFT_DUMP_DETAIL_V WITH (NOLOCK) 
) 
 
SELECT  
	[shift].shiftflag,
	[shift].siteflag,
	[shift].shiftid,
	dc.truck,
	pop.eqmttype,
	UPPER(pop.Operator) as toper,
	pop.OperatorImageURL,
	pop.OperatorID,
	pop.[Payload] AS AVG_Payload,
	pop.[PayloadTarget] AS AVG_PayloadTarget,
	dc.deltac,
	pop.DeltaCTarget AS Delta_c_target,
	dc.idletime,
	pop.idletimetarget,
	dc.spottime,
	pop.SpottingTarget AS spottarget,
	dc.loadtime,
	pop.LoadingTarget AS loadtarget,
	dc.DumpingTime,
	pop.DumpingTarget AS dumpingtarget,
	dc.EFH,
	pop.EFHtarget,
	dc.DumpingAtStockpile,
	pop.DumpsAtStockpileTarget AS dumpingatStockpileTarget,
	dc.DumpingAtCrusher,
	pop.DumpsAtCrusherTarget AS dumpingAtCrusherTarget,
	dc.LoadedTravel,
	pop.LoadedTravelTarget,
	dc.EmptyTravel,
	pop.EmptyTravelTarget,
	pop.AvgUseOfAvailibility AS useOfAvailability,
	pop.AvgUseOfAvailibilityTarget AS useOfAvailabilityTarget,
	pop.TotalMaterialDelivered,
	pop.TotalMaterialDeliveredTarget,
	pop.[location] AS [destination],
	pit.Pushback AS Pit,
	pop.ReasonId AS reasonidx,
	pop.ReasonDesc AS reasons,
	pop.StatusName AS eqmtcurrstatus 
FROM mor.CONOPS_MOR_SHIFT_INFO_V [shift] 
LEFT JOIN DELTAC dc
	ON dc.shiftindex = [shift].ShiftIndex 
LEFT JOIN [mor].[CONOPS_MOR_TRUCK_POPUP] pop WITH (NOLOCK)
	ON [shift].shiftflag = pop.shiftflag
	AND dc.truck = pop.TruckID 
LEFT JOIN PIT pit
	ON pit.ShiftId = [shift].ShiftId
	AND pit.TRUCK = dc.truck
	AND pit.row_num = 1 

