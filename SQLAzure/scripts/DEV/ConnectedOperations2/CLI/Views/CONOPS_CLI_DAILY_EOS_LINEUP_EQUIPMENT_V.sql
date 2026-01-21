CREATE VIEW [CLI].[CONOPS_CLI_DAILY_EOS_LINEUP_EQUIPMENT_V] AS
  
  
  
-- SELECT * FROM [cli].[CONOPS_CLI_DAILY_EOS_LINEUP_EQUIPMENT_V]  WHERE [shiftflag] = 'CURR'  
CREATE VIEW [cli].[CONOPS_CLI_DAILY_EOS_LINEUP_EQUIPMENT_V]   
AS  
  
  
SELECT  
siteflag,  
shiftflag,  
shiftid,  
'Shovels' AS Equipment,  
COUNT(ShovelID) AS EquipmentAvailable  
FROM [cli].[CONOPS_CLI_DAILY_EOS_LINEUP_SHOVEL_V]   
GROUP BY siteflag, shiftflag, shiftid  
  
UNION ALL  
  
SELECT  
siteflag,  
shiftflag,  
shiftid,  
'Shovels' AS Equipment,  
0 AS EquipmentAvailable  
FROM [cli].[CONOPS_CLI_EOS_SHIFT_INFO_V]  
  
UNION ALL  
  
SELECT  
siteflag,  
shiftflag,  
shiftid,  
'Loaders' AS Equipment,  
COUNT(ShovelID) AS EquipmentAvailable  
FROM [cli].[CONOPS_CLI_DAILY_EOS_LINEUP_SHOVEL_V]   
WHERE ShovelID LIKE 'L%'  
GROUP BY siteflag, shiftflag, shiftid  
  
UNION ALL  
  
SELECT  
siteflag,  
shiftflag,  
shiftid,  
'Loaders' AS Equipment,  
0 AS EquipmentAvailable  
FROM [cli].[CONOPS_CLI_EOS_SHIFT_INFO_V]  
GROUP BY siteflag, shiftflag, shiftid  
  
UNION ALL  
  
SELECT  
siteflag,  
shiftflag,  
shiftid,  
'Trucks' AS Equipment,  
ISNULL(COUNT(TruckID),0) AS EquipmentAvailable  
FROM [cli].[CONOPS_CLI_DAILY_EOS_LINEUP_TRUCK_V]  
GROUP BY siteflag, shiftflag,shiftid  
  
UNION ALL  
  
SELECT  
siteflag,  
shiftflag,  
shiftid,  
'Trucks' AS Equipment,  
0 AS EquipmentAvailable  
FROM [cli].[CONOPS_CLI_EOS_SHIFT_INFO_V]  
GROUP BY siteflag, shiftflag, shiftid  
  
  
UNION ALL  
  
SELECT  
siteflag,  
shiftflag,  
shiftid,  
'Drills' AS Equipment,  
ISNULL(COUNT(DrillId),0) AS EquipmentAvailable  
FROM [cli].[CONOPS_CLI_DAILY_EOS_LINEUP_DRILL_V]  
GROUP BY siteflag, shiftflag, shiftid  
  
UNION ALL  
  
SELECT  
siteflag,  
shiftflag,  
shiftid,  
'Drills' AS Equipment,  
0 AS EquipmentAvailable  
FROM [cli].[CONOPS_CLI_EOS_SHIFT_INFO_V]  
GROUP BY siteflag, shiftflag, shiftid  
  
  
UNION ALL  
  
SELECT  
siteflag,  
shiftflag,  
shiftid,  
'Water Trucks' AS Equipment,  
ISNULL(COUNT(SupportEquipment),0) AS EquipmentAvailable  
FROM [cli].[CONOPS_CLI_DAILY_EOS_LINEUP_EQMT_OTHER_V]  
WHERE SupportEquipment = 'Water Truck'  
GROUP BY siteflag, shiftflag, shiftid  
  
UNION ALL  
  
SELECT  
siteflag,  
shiftflag,  
shiftid,  
'Water Trucks' AS Equipment,  
0 AS EquipmentAvailable  
FROM [cli].[CONOPS_CLI_EOS_SHIFT_INFO_V]  
GROUP BY siteflag, shiftflag, shiftid  
  
  
UNION ALL  
  
SELECT  
siteflag,  
shiftflag,  
shiftid,  
'Dozer' AS Equipment,  
ISNULL(COUNT(SupportEquipment),0) AS EquipmentAvailable  
FROM [cli].[CONOPS_CLI_DAILY_EOS_LINEUP_EQMT_OTHER_V]  
WHERE SupportEquipment = 'Dozer'  
GROUP BY siteflag, shiftflag, shiftid  
  
UNION ALL  
  
SELECT  
siteflag,  
shiftflag,  
shiftid,  
'Dozer' AS Equipment,  
0 AS EquipmentAvailable  
FROM [cli].[CONOPS_CLI_EOS_SHIFT_INFO_V]  
GROUP BY siteflag, shiftflag, shiftid  
  
  
UNION ALL  
  
SELECT  
siteflag,  
shiftflag,  
shiftid,  
'Other' AS Equipment,  
ISNULL(COUNT(SupportEquipment),0) AS EquipmentAvailable  
FROM [cli].[CONOPS_CLI_DAILY_EOS_LINEUP_EQMT_OTHER_V]  
WHERE SupportEquipment NOT IN ('Dozer','Water Truck')  
GROUP BY siteflag, shiftflag,shiftid  
  
UNION ALL  
  
SELECT  
siteflag,  
shiftflag,  
shiftid,  
'Other' AS Equipment,  
0 AS EquipmentAvailable  
FROM [cli].[CONOPS_CLI_EOS_SHIFT_INFO_V]  
GROUP BY siteflag, shiftflag, shiftid  
  
  
  
