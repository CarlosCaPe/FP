CREATE VIEW [cer].[CONOPS_CER_SHOVEL_OVERLOAD_V] AS







--SELECT * FROM [CER].[CONOPS_CER_SHOVEL_OVERLOAD_V] WHERE SHIFTFLAG = 'CURR'  
CREATE VIEW [cer].[CONOPS_CER_SHOVEL_OVERLOAD_V]  
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
	CASE WHEN td.EQMTTYPE LIKE '%793%' THEN 264
		WHEN td.EQMTTYPE LIKE '%930E%' THEN 350
		WHEN td.EQMTTYPE LIKE '%980E-5%' THEN 410
		ELSE NULL END AS LoadLimit
FROM CER.shift_load sl WITH (NOLOCK)
LEFT JOIN CER.shift_eqmt s WITH (NOLOCK)
	ON s.shift_eqmt_id = sl.FieldExcav AND s.shiftid = sl.shiftid  
LEFT JOIN CER.shift_eqmt t WITH (NOLOCK)
	ON t.shift_eqmt_id = sl.FieldTruck AND t.shiftid = sl.shiftid
LEFT JOIN [CER].[CONOPS_CER_TRUCK_DETAIL_V] td WITH (NOLOCK)
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


