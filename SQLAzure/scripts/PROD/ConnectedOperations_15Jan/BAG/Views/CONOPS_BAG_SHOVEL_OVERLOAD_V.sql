CREATE VIEW [BAG].[CONOPS_BAG_SHOVEL_OVERLOAD_V] AS








--SELECT * FROM [bag].[CONOPS_BAG_SHOVEL_OVERLOAD_V] WHERE SHIFTFLAG = 'CURR'  
CREATE VIEW [bag].[CONOPS_BAG_SHOVEL_OVERLOAD_V]  
AS  

WITH ShovelLoad AS(
SELECT
	b.SITEFLAG,
	b.shiftflag,
	b.SHIFTID,
	SHOVEL_NAME AS ShovelId,
	TRUCK_NAME AS TruckId,
	TRUCK_EQUIP_CLASS AS TruckType,
	MEASURED_PAYLOAD_SHORT_TONS AS FieldTons,
	CASE WHEN TRUCK_EQUIP_CLASS LIKE '%793%' THEN 291
		ELSE NULL END AS LoadLimit
FROM BAG.FLEET_SHOVEL_CYCLE_V a
LEFT JOIN BAG.CONOPS_BAG_SHIFT_INFO_V b
	ON a.SHIFT_ID = b.SHIFTID
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








