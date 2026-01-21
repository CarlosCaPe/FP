CREATE VIEW [BAG].[CONOPS_BAG_TM_TRAFFIC_SHOVEL_V] AS


  

   
--SELECT * FROM [bag].[CONOPS_BAG_TM_TRAFFIC_SHOVEL_V] WITH (NOLOCK) WHERE SHIFTFLAG = 'CURR'
CREATE VIEW [bag].[CONOPS_BAG_TM_TRAFFIC_SHOVEL_V]
AS

WITH Shovel AS(
SELECT
	s.shiftflag,
	s.siteflag,
	s.ShovelID AS LocationID,
	s.Location,
	s.StatusName AS Status,
	'Shovel' AS TrafficType,
	p.FieldX AS FieldXloc,
	p.FieldY AS FieldYloc,
	p.FieldZ
FROM BAG.CONOPS_BAG_SHOVEL_INFO_V s WITH(NOLOCK)
LEFT JOIN BAG.FLEET_PIT_MACHINE_C p WITH(NOLOCK)
	ON s.shiftindex = p.SHIFTINDEX
	AND s.ShovelId = p.EquipmentId
WHERE s.ShovelId LIKE 'S%'
)

SELECT 
[s].SHIFTFLAG 
,[s].SITEFLAG
,[s].TrafficType
,[s].LocationID
,[s].Status
,[t].TruckID
,CASE WHEN [t].Location = [s].Location
	THEN 1
	ELSE 0
	END AS [IsTruckAtLocation]
,CASE WHEN [s].FieldXloc IS NOT NULL AND [t].FieldXloc IS NOT NULL
	THEN ([s].FieldXloc - [t].FieldXloc)  / 60.0 
	ELSE 0
	END AS dx
,CASE WHEN [s].FieldYloc IS NOT NULL AND [t].FieldYloc IS NOT NULL
	THEN ([s].FieldYloc - [t].FieldYloc) / 60.0  
	ELSE 0
	END AS dy
,CASE WHEN [t].Location IS NOT NULL
	THEN [t].FieldVelocity / 60.0 
	ELSE NULL
	END AS Velocity,
[t].Location AS PushbackId
FROM Shovel [s]
LEFT JOIN [bag].[CONOPS_BAG_TRUCK_DETAIL_V] [t] WITH (NOLOCK)   
ON [s].SHIFTFLAG = [t].shiftflag
	AND [s].SITEFLAG = [t].siteflag
	AND [s].Location = [t].Location

  


