CREATE VIEW [MOR].[CONOPS_MOR_TRUCK_TOTAL_MATERIAL_DELIVERED_V] AS


CREATE VIEW [MOR].[CONOPS_MOR_TRUCK_TOTAL_MATERIAL_DELIVERED_V]
AS

SELECT
a.Shiftid,
a.TruckId,
SUM(b.tons) AS TotalMaterialDelivered,
SUM(c.ShovelTarget) AS TotalMaterialDeliveredTarget
FROM [mor].[CONOPS_MOR_TRUCK_DETAIL_V] a

LEFT JOIN (
SELECT
shiftid,
shovelid,
SUM(totalmaterialmined) AS tons
FROM [mor].[CONOPS_MOR_OVERVIEW_V]
GROUP BY shiftid,shovelid) b
ON a.shiftid = b.shiftid AND a.AssignedShovel = b.shovelid

LEFT JOIN (
SELECT
Shiftid,
Shovelid,
SUM(ShovelTarget) AS ShovelTarget
FROM [mor].[CONOPS_MOR_SHOVEL_SHIFT_TARGET_V]
GROUP BY Shiftid,Shovelid) c
ON a.shiftid = c.shiftid AND a.AssignedShovel = c.shovelid



GROUP BY a.shiftid, a.truckid

