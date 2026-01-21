CREATE VIEW [CHI].[CONOPS_CHI_SHOVEL_OVERLOAD_V] AS








--SELECT * FROM [CHI].[CONOPS_CHI_SHOVEL_OVERLOAD_V] WHERE SHIFTFLAG = 'CURR'  
CREATE VIEW [chi].[CONOPS_CHI_SHOVEL_OVERLOAD_V]  
AS  

WITH ShovelLoad AS(
SELECT
	td.siteflag,
	td.shiftflag,
	sl.shiftid,  
	s.FieldId AS [ShovelId],
	t.FieldId AS [TruckId],
	td.EQMTTYPE AS [TruckType],
	sl.FieldTons,
	CASE WHEN td.EQMTTYPE LIKE '%793%' THEN 300
		ELSE NULL END AS LoadLimit
FROM CHI.shift_load sl WITH (NOLOCK)
LEFT JOIN CHI.shift_eqmt s WITH (NOLOCK)
	ON s.id = sl.FieldExcav AND s.shiftid = sl.shiftid  
LEFT JOIN CHI.shift_eqmt t WITH (NOLOCK)
	ON t.id = sl.FieldTruck AND t.shiftid = sl.shiftid
LEFT JOIN [CHI].[CONOPS_CHI_TRUCK_DETAIL_V] td WITH (NOLOCK)
	ON t.FieldID = td.TruckID AND td.shiftid = sl.shiftid
WHERE td.shiftflag IS NOT NULL
)

SELECT
	siteflag,
	shiftflag,
	shiftid,  
	ShovelId,
	TruckId,
	FieldTons AS Tonnage,
	LoadLimit,
	COUNT(FieldTons) AS Overload
FROM ShovelLoad
WHERE FieldTons > LoadLimit
GROUP BY siteflag, shiftflag, shiftid, ShovelId, TruckId, FieldTons, LoadLimit



