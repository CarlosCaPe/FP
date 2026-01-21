CREATE VIEW [saf].[CONOPS_SAF_DELTA_C_ROUTE_BREAKDOWN_V] AS




--select * from [SAF].[CONOPS_SAF_DELTA_C_ROUTE_BREAKDOWN_V]
CREATE VIEW [SAF].[CONOPS_SAF_DELTA_C_ROUTE_BREAKDOWN_V]
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
FROM SAF.CONOPS_SAF_SHIFT_INFO_V si
LEFT JOIN dbo.delta_c dc WITH(NOLOCK)
	ON dc.site_code = si.siteflag
	AND dc.shiftindex = si.shiftindex
LEFT JOIN SAF.CONOPS_SAF_TRUCK_DETAIL_V t
	ON t.shiftindex = si.shiftindex
	AND t.TruckID = dc.Truck
LEFT JOIN SAF.CONOPS_SAF_SHOVEL_INFO_V s
	ON s.shiftindex = si.shiftindex
	AND dc.EXCAV = s.ShovelId
LEFT JOIN [SAF].PIT_LOC_C loc
	ON dc.DUMPNAME = loc.FieldId
	AND dc.SHIFTINDEX = loc.SHIFTINDEX
	AND dc.SITE_CODE = loc.siteflag
LEFT JOIN [SAF].PIT_LOC_C r
	ON r.Id = loc.FieldRegion
	AND r.SHIFTINDEX = loc.SHIFTINDEX 
	AND r.siteflag = loc.siteflag
WHERE dc.site_code = 'SAF'



