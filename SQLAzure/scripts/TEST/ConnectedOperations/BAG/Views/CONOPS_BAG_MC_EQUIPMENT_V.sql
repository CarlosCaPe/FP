CREATE VIEW [BAG].[CONOPS_BAG_MC_EQUIPMENT_V] AS


/******************************************************************
* PROCEDURE : [bag].[CONOPS_BAG_MC_EQUIPMENT_V]
* PURPOSE : 
* NOTES: 
* CREATED : sxavier, 08 Aug 2023
* SAMPLE : 
 1. SELECT * FROM [bag].[CONOPS_BAG_MC_EQUIPMENT_V]

* MODIFIED DATE AUTHOR DESCRIPTION
*------------------------------------------------------------------
* {08 Aug 2023}	 {sxavier}	{Initial Created}
* {13 Oct 2023}	 {lwasini}	{Change Drill source to Asset Efficiency}
*******************************************************************/


CREATE VIEW [BAG].[CONOPS_BAG_MC_EQUIPMENT_V]
AS



SELECT DISTINCT
'Truck' AS EquipmentType,
'0' AS EquipmentTypeCode,
EQMT AS EquipmentId
FROM [bag].[asset_efficiency] WITH (NOLOCK)
WHERE UNITTYPE = 'Truck'

UNION ALL


SELECT DISTINCT
'Shovel' AS EquipmentType,
'1' AS EquipmentTypeCode,
EQMT AS EquipmentId
FROM [bag].[asset_efficiency] WITH (NOLOCK)
WHERE UNITTYPE IN ('Shovel','Loader')


UNION ALL
/*
SELECT DISTINCT
 'Drill' AS EquipmentType,
 '2' AS EquipmentTypeCode,
 REPLACE(DRILL_ID, ' ','') AS EquipmentId
FROM [dbo].[FR_DRILLING_SCORES] WITH (NOLOCK)
WHERE [SITE_CODE] = 'BAG' 
*/

SELECT DISTINCT
'Drill' AS EquipmentType,
'2' AS EquipmentTypeCode,
DRILL_ID AS EquipmentId
FROM [bag].[drill_asset_efficiency_v] WITH (NOLOCK)


UNION ALL

SELECT DISTINCT
'Crusher' AS EquipmentType,
'3' AS EquipmentTypeCode,
CASE WHEN EquipmentId IN ('Crusher 2', 'Crusher2') THEN 'Crusher 2' 
WHEN EquipmentId IN ('SMALL CR_T') THEN 'Small Crusher' END AS EquipmentId
FROM bag.fleet_pit_machine_c WITH (NOLOCK)
WHERE EQMTTYPE = 'Crusher'


UNION ALL

SELECT DISTINCT
'Support' AS EquipmentType,
'4' AS EquipmentTypeCode,
EQMT AS EquipmentId
FROM [bag].[asset_efficiency] WITH (NOLOCK)
WHERE UNITTYPE NOT IN('Truck','Shovel','Loader','Drill')





