CREATE VIEW [ABR].[CONOPS_ABR_DELTA_C_ROUTE_BREAKDOWN_V] AS




--select * from [ABR].[CONOPS_ABR_DELTA_C_ROUTE_BREAKDOWN_V]
CREATE VIEW [ABR].[CONOPS_ABR_DELTA_C_ROUTE_BREAKDOWN_V]
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
	dc.REGION AS PushBack,
	DELTA_C AS DeltaC,
	TRUCK_IDLEDELTA AS TruckIdle,
	SHOVEL_IDLEDELTA AS ShovelIdle,
	SPOTDELTA AS Spotting,
	LOADDELTA AS Loading,
	LT_DELTA AS LoadedTravel,
	ET_DELTA AS EmptyTravel,
	DUMPDELTA AS Dumping,
	DUMPINGDELTA AS DumpingAtStockpile,
	CRUSHERDELTA AS DumpingAtCrusher
FROM ABR.CONOPS_ABR_SHIFT_INFO_V si
LEFT JOIN dbo.delta_c dc WITH(NOLOCK)
	ON dc.site_code = 'ELA'
	AND dc.shiftindex = si.shiftindex
LEFT JOIN ABR.CONOPS_ABR_TRUCK_DETAIL_V t
	ON t.shiftindex = si.shiftindex
	AND t.TruckID = dc.Truck
LEFT JOIN ABR.CONOPS_ABR_SHOVEL_INFO_V s
	ON s.shiftindex = si.shiftindex
	AND dc.EXCAV = s.ShovelId




