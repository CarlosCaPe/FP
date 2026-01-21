CREATE VIEW [SIE].[CONOPS_SIE_DELTA_C_ROUTE_BREAKDOWN_V] AS




--select * from [SIE].[CONOPS_SIE_DELTA_C_ROUTE_BREAKDOWN_V]
CREATE VIEW [SIE].[CONOPS_SIE_DELTA_C_ROUTE_BREAKDOWN_V]
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
	r.FieldId AS Pushback,
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
FROM SIE.CONOPS_SIE_SHIFT_INFO_V si
LEFT JOIN dbo.delta_c dc WITH(NOLOCK)
	ON dc.site_code = si.siteflag
	AND dc.shiftindex = si.shiftindex
LEFT JOIN SIE.CONOPS_SIE_TRUCK_DETAIL_V t
	ON t.shiftindex = si.shiftindex
	AND t.TruckID = dc.Truck
LEFT JOIN SIE.CONOPS_SIE_SHOVEL_INFO_V s
	ON s.shiftindex = si.shiftindex
	AND dc.EXCAV = s.ShovelId
LEFT JOIN [SIE].shift_loc loc
	ON dc.DUMPNAME = loc.FieldId
	AND si.shiftid = loc.shiftid
	AND dc.SITE_CODE = loc.siteflag
LEFT JOIN [SIE].shift_loc r
	ON r.Id = loc.FieldRegion
	AND r.shiftid = loc.shiftid
	AND r.siteflag = loc.siteflag
WHERE dc.site_code = 'SIE'



