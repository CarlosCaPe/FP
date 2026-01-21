CREATE VIEW [CLI].[CONOPS_CLI_DELTA_C_ROUTE_BREAKDOWN_V] AS




--select * from [CLI].[CONOPS_CLI_DELTA_C_ROUTE_BREAKDOWN_V]
CREATE VIEW [CLI].[CONOPS_CLI_DELTA_C_ROUTE_BREAKDOWN_V]
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
	CASE WHEN dc.DUMPNAME NOT LIKE '%CSP%'
		AND dc.DUMPNAME NOT LIKE '%GRAVEL%'
		AND dc.DUMPNAME NOT LIKE '%SNW%'
		AND dc.DUMPNAME NOT LIKE '%SNOW%'
		AND dc.DUMPNAME NOT LIKE '%SLS%'
		AND dc.DUMPNAME NOT LIKE '%INPIT%'
		AND dc.DUMPNAME NOT LIKE '%IN PIT%'
	THEN 'EXPIT'
	ELSE r.FieldId
	END AS PushBack,
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
FROM CLI.CONOPS_CLI_SHIFT_INFO_V si
LEFT JOIN dbo.delta_c dc WITH(NOLOCK)
	ON dc.site_code = 'CLI'
	AND dc.shiftindex = si.shiftindex
LEFT JOIN CLI.CONOPS_CLI_TRUCK_DETAIL_V t
	ON t.shiftindex = si.shiftindex
	AND t.TruckID = dc.Truck
LEFT JOIN CLI.CONOPS_CLI_SHOVEL_INFO_V s
	ON s.shiftindex = si.shiftindex
	AND dc.EXCAV = s.ShovelId
LEFT JOIN [cli].PIT_LOC_C loc WITH (NOLOCK)
	ON dc.DUMPNAME = loc.FieldId
	AND dc.SHIFTINDEX = loc.SHIFTINDEX
	AND dc.SITE_CODE = 'CLI' 
	AND loc.siteflag = 'CMX'
LEFT JOIN [cli].PIT_LOC_C r WITH (NOLOCK)   
	ON r.Id = loc.FieldRegion
	AND r.SHIFTINDEX = loc.SHIFTINDEX AND r.siteflag = loc.siteflag
WHERE site_code = 'CLI'



