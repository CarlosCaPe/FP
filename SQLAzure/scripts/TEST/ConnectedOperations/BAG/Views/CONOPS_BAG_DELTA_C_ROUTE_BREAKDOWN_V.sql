CREATE VIEW [BAG].[CONOPS_BAG_DELTA_C_ROUTE_BREAKDOWN_V] AS




--select * from [BAG].[CONOPS_BAG_DELTA_C_ROUTE_BREAKDOWN_V]
CREATE VIEW [BAG].[CONOPS_BAG_DELTA_C_ROUTE_BREAKDOWN_V]
AS

SELECT
	si.siteflag,
	si.shiftid,
	si.shiftindex,
	si.shiftflag,
	EXCAV AS ShovelID,
	s.EQMTTYPE AS ShovelType,
	s.StatusName AS ShovelStatus,
	TRUCK AS TruckID,
	t.EQMTTYPE AS TruckType,
	t.StatusName AS TruckStatus,
	DUMPNAME AS Route,
	CASE WHEN LEFT(dc.grade,4) BETWEEN '0000' AND '9999'
		THEN SUBSTRING(dc.grade,6,2)
		ELSE grade
	END AS PushBack,
	DELTA_C AS DeltaC,
	TRUCK_IDLEDELTA AS TruckIdle,
	SHOVEL_IDLEDELTA AS ShovelIdle,
	SPOTDELTA AS Spotting,
	LOADDELTA AS Loading,
	LT_DELTA AS LoadedTravel,
	ET_DELTA AS EmptyTravel,
	DUMPDELTA AS Dumping,
	CASE WHEN unit = 'Stockpile' THEN COALESCE([dumpdelta], 0) END AS DumpingAtStockpile,    
	CASE WHEN unit = 'Crusher' THEN COALESCE([dumpdelta], 0) END AS DumpingAtCrusher   
FROM BAG.CONOPS_BAG_SHIFT_INFO_V si
LEFT JOIN dbo.delta_c dc WITH(NOLOCK)
	ON dc.site_code = si.siteflag
	AND dc.shiftindex = si.shiftindex
LEFT JOIN BAG.CONOPS_BAG_TRUCK_DETAIL_V t
	ON t.shiftindex = si.shiftindex
	AND t.TruckID = dc.Truck
LEFT JOIN BAG.CONOPS_BAG_SHOVEL_INFO_V s
	ON s.shiftindex = si.shiftindex
	AND dc.EXCAV = s.ShovelId




