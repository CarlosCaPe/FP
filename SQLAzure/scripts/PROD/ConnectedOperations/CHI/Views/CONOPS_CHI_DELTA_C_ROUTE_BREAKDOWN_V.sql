CREATE VIEW [CHI].[CONOPS_CHI_DELTA_C_ROUTE_BREAKDOWN_V] AS

--select * from [CHI].[CONOPS_CHI_DELTA_C_ROUTE_BREAKDOWN_V]
CREATE VIEW [CHI].[CONOPS_CHI_DELTA_C_ROUTE_BREAKDOWN_V]
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
	FROM CHI.asset_efficiency WITH(NOLOCK)
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
	CASE WHEN LEFT(grade,4) BETWEEN '0000' AND '9999' 
		THEN SUBSTRING(grade,6, 2)
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
	DUMPINGDELTA AS DumpingAtStockpile,
	CRUSHERDELTA AS DumpingAtCrusher 
FROM CHI.CONOPS_CHI_SHIFT_INFO_V si
LEFT JOIN dbo.delta_c dc WITH(NOLOCK)
	ON dc.site_code = si.siteflag
	AND dc.shiftindex = si.shiftindex
LEFT JOIN EqStat t
	ON t.ShiftId = si.ShiftId
	AND t.EQMT = dc.Truck
LEFT JOIN EqStat s
	ON s.ShiftId = si.ShiftId
	AND dc.EXCAV = s.EQMT

