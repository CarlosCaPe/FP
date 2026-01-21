CREATE VIEW [CLI].[CONOPS_CLI_DELTA_C_ROUTE_BREAKDOWN_V] AS

--select * from [CLI].[CONOPS_CLI_DELTA_C_ROUTE_BREAKDOWN_V]
CREATE VIEW [CLI].[CONOPS_CLI_DELTA_C_ROUTE_BREAKDOWN_V]
AS

WITH EqStat AS(
SELECT
	ShiftId,
	EQMT,
	EQMTTYPE,
	UNITTYPE,
	StatusName
FROM (
	SELECT
		ShiftId,
		EQMT,
		EQMTTYPE,
		UNITTYPE,
		STATUS AS StatusName,
		ROW_NUMBER() OVER(PARTITION BY ShiftId, EQMT ORDER BY StartDateTime DESC) AS RN
	FROM CLI.asset_efficiency WITH(NOLOCK)
) a
WHERE RN = 1
)

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
LEFT JOIN EqStat t
	ON t.ShiftId = si.ShiftId
	AND t.EQMT = dc.Truck
LEFT JOIN EqStat s
	ON s.ShiftId = si.ShiftId
	AND dc.EXCAV = s.EQMT
LEFT JOIN cli.shift_loc loc
	ON dc.DUMPNAME = loc.FieldId
	AND si.ShiftId = loc.ShiftId
LEFT JOIN cli.shift_loc r
	ON r.Id = loc.FieldRegion
	AND r.ShiftId = loc.ShiftId


