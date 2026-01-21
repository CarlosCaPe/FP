CREATE VIEW [TYR].[CONOPS_TYR_DELTA_C_COMPONENT_V] AS




--SELECT * FROM TYR.CONOPS_TYR_DELTA_C_COMPONENT_V WHERE SHIFTFLAG = 'CURR' ORDER BY MinsOverExpected DESC
CREATE VIEW TYR.CONOPS_TYR_DELTA_C_COMPONENT_V
AS

WITH TotalCycleCount AS(
SELECT 
	COUNT(*) TotalShiftCycle,
	ROUND(COUNT(*) / 12,0) AS TotalCycle
FROM dbo.DELTA_C dc WITH(NOLOCK)
LEFT JOIN TYR.CONOPS_TYR_SHIFT_INFO_V si
	ON dc.shiftindex = si.shiftindex
WHERE dc.SITE_CODE = 'TYR'
	AND si.SHIFTFLAG = 'PREV'
),

CycleDeltaCurr AS (
SELECT TOP (SELECT TotalCycle FROM TotalCycleCount)
	SITE_CODE,
	'CURR' AS SHIFTFLAG,
	dc.EXCAV,
	dc.DUMPNAME,
	CONCAT(dc.EXCAV, '-', dc.DUMPNAME) AS Route,
	CONCAT(dc.BENCH, '>>', dc.DUMPNAME) AS RouteName,
	CONCAT(dc.DUMPNAME, '-', dc.EXCAV) AS ReverseRoute,
	CONCAT(dc.DUMPNAME, '>>', dc.BENCH) AS ReverseRouteName,
	dc.TRUCK_IDLEDELTA AS Queueing,
	dc.SPOTDELTA AS Spotting,
	dc.LOADDELTA AS Loading,
	dc.DUMPDELTA AS Dumping,
	dc.ET_DELTA AS EmptyTravel,
	dc.LT_DELTA AS FullTravel,
	dc.DELTA_C AS Delta_C,
	dc.TIMEEMPTY_TS
FROM dbo.DELTA_C dc WITH(NOLOCK)
WHERE dc.SITE_CODE = 'TYR'
ORDER BY TIMEEMPTY_TS DESC
),

CycleDeltaPrev AS (
SELECT TOP (SELECT TotalCycle FROM TotalCycleCount)
	SITE_CODE,
	'PREV' AS SHIFTFLAG,
	dc.EXCAV,
	dc.DUMPNAME,
	CONCAT(dc.EXCAV, '-', dc.DUMPNAME) AS Route,
	CONCAT(dc.BENCH, '>>', dc.DUMPNAME) AS RouteName,
	CONCAT(dc.DUMPNAME, '-', dc.EXCAV) AS ReverseRoute,
	CONCAT(dc.DUMPNAME, '>>', dc.BENCH) AS ReverseRouteName,
	dc.TRUCK_IDLEDELTA AS Queueing,
	dc.SPOTDELTA AS Spotting,
	dc.LOADDELTA AS Loading,
	dc.DUMPDELTA AS Dumping,
	dc.ET_DELTA AS EmptyTravel,
	dc.LT_DELTA AS FullTravel,
	dc.DELTA_C AS Delta_C,
	dc.TIMEEMPTY_TS
FROM dbo.DELTA_C dc WITH(NOLOCK)
LEFT JOIN TYR.CONOPS_TYR_SHIFT_INFO_V si
	ON dc.shiftindex = si.shiftindex
WHERE dc.SITE_CODE = 'TYR'
	AND si.shiftflag = 'PREV'
ORDER BY TIMEEMPTY_TS DESC
),

CycleDelta AS (
SELECT * FROM CycleDeltaCurr
UNION ALL
SELECT * FROM CycleDeltaPrev
),

ContributionDeltaC AS(
SELECT
	SITE_CODE,
	SHIFTFLAG,
	SUM(Delta_C) AS MinsOverExpectedTotal,
	AVG(Delta_C) AS Delta_C
FROM CycleDelta
GROUP BY
	SITE_CODE,
	SHIFTFLAG
),

EmptyTravel AS (
SELECT
	SITE_CODE,
	SHIFTFLAG,
	'Empty Travel' AS Component,
	ReverseRoute AS ActionAt,
	ReverseRouteName AS PlotName,
	SUM(EmptyTravel) AS MinsOverExpected,
	COUNT(*) AS CycleCount,
	AVG(EmptyTravel) AS ComponentDeltaC
FROM CycleDelta
GROUP BY SITE_CODE, SHIFTFLAG, ReverseRoute, ReverseRouteName
),

FullTravel AS (
SELECT 
	SITE_CODE,
	SHIFTFLAG,
	'Full Travel' AS Component,
	Route AS ActionAt,
	RouteName AS PlotName,
	SUM(FullTravel) AS MinsOverExpected,
	COUNT(*) AS CycleCount,
	AVG(FullTravel) AS ComponentDeltaC
FROM CycleDelta
GROUP BY SITE_CODE, SHIFTFLAG, Route, RouteName
),

Dumping AS (
SELECT 
	SITE_CODE,
	SHIFTFLAG,
	'Dumping' AS Component,
	DUMPNAME AS ActionAt,
	NULL AS PlotName,
	SUM(Dumping) AS MinsOverExpected,
	COUNT(*) AS CycleCount,
	AVG(Dumping) AS ComponentDeltaC
FROM CycleDelta
GROUP BY SITE_CODE, SHIFTFLAG, DUMPNAME
),

Queueing AS (
SELECT 
	SITE_CODE,
	SHIFTFLAG,
	'Queueing' AS Component,
	EXCAV AS ActionAt,
	NULL AS PlotName,
	SUM(Queueing) AS MinsOverExpected,
	COUNT(*) AS CycleCount,
	AVG(Queueing) AS ComponentDeltaC
FROM CycleDelta
GROUP BY SITE_CODE, SHIFTFLAG, EXCAV
),

Spotting AS (
SELECT 
	SITE_CODE,
	SHIFTFLAG,
	'Spotting' AS Component,
	EXCAV AS ActionAt,
	NULL AS PlotName,
	SUM(Spotting) AS MinsOverExpected,
	COUNT(*) AS CycleCount,
	AVG(Spotting) AS ComponentDeltaC
FROM CycleDelta
GROUP BY SITE_CODE, SHIFTFLAG, EXCAV
),

Loading AS (
SELECT 
	SITE_CODE,
	SHIFTFLAG,
	'Loading' AS Component,
	EXCAV AS ActionAt,
	NULL AS PlotName,
	SUM(Loading) AS MinsOverExpected,
	COUNT(*) AS CycleCount,
	AVG(Loading) AS ComponentDeltaC
FROM CycleDelta
GROUP BY SITE_CODE, SHIFTFLAG, EXCAV
),

AllComponent AS (
SELECT * FROM EmptyTravel
UNION ALL
SELECT * FROM Queueing
UNION ALL
SELECT * FROM 