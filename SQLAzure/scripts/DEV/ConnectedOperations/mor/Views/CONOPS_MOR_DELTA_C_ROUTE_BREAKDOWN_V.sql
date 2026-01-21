CREATE VIEW [mor].[CONOPS_MOR_DELTA_C_ROUTE_BREAKDOWN_V] AS




--select * from [MOR].[CONOPS_MOR_DELTA_C_ROUTE_BREAKDOWN_V]
CREATE VIEW [MOR].[CONOPS_MOR_DELTA_C_ROUTE_BREAKDOWN_V]
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
	CASE 
		WHEN REPLACE(SUBSTRING(grade, 6, 3), '-', '') LIKE '%WT%' THEN 'W COPPER 10'
		WHEN REPLACE(SUBSTRING(grade, 6, 3), '-', '') LIKE '%WF%' THEN 'W COPPER 14'
		WHEN REPLACE(SUBSTRING(grade, 6, 3), '-', '') LIKE '%SR%' THEN 'SUN RIDGE MINE'
		WHEN REPLACE(SUBSTRING(grade, 6, 3), '-', '') LIKE '%AM%' THEN 'AMT MINE'
		WHEN REPLACE(SUBSTRING(grade, 6, 3), '-', '') LIKE '%WC%' THEN 'W COPPER'
		WHEN REPLACE(SUBSTRING(grade, 6, 3), '-', '') LIKE 'GAR%' THEN 'GAR DUMPS'
		WHEN REPLACE(SUBSTRING(grade, 6, 3), '-', '') LIKE 'SD%' THEN 'SLV DUMPS'
		WHEN REPLACE(SUBSTRING(grade, 6, 3), '-', '') LIKE 'GF%' THEN 'GARFIELD MINE'
		WHEN REPLACE(SUBSTRING(grade, 6, 3), '-', '') LIKE 'LR%' THEN 'LRH DUMPS'
		WHEN REPLACE(SUBSTRING(grade, 6, 3), '-', '') LIKE 'CO%' THEN 'CORONADO'
		WHEN REPLACE(SUBSTRING(grade, 6, 3), '-', '') LIKE 'ILL%' 
			OR REPLACE(SUBSTRING(grade, 6, 3), '-', '') LIKE '%ML2%' THEN 'MILL'
		WHEN REPLACE(SUBSTRING(grade, 6, 3), '-', '') LIKE 'FL%' THEN 'MFL'
		WHEN REPLACE(SUBSTRING(grade, 6, 3), '-', '') LIKE 'SH%' THEN 'SHANNON'
	ELSE REPLACE(SUBSTRING(grade, 6, 3), '-', '')
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
FROM MOR.CONOPS_MOR_SHIFT_INFO_V si
LEFT JOIN dbo.delta_c dc WITH(NOLOCK)
	ON dc.site_code = si.siteflag
	AND dc.shiftindex = si.shiftindex
LEFT JOIN MOR.CONOPS_MOR_TRUCK_DETAIL_V t
	ON t.shiftindex = si.shiftindex
	AND t.TruckID = dc.Truck
LEFT JOIN MOR.CONOPS_MOR_SHOVEL_INFO_V s
	ON s.shiftindex = si.shiftindex
	AND dc.EXCAV = s.ShovelId




