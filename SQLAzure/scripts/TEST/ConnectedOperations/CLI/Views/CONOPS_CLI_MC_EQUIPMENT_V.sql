CREATE VIEW [CLI].[CONOPS_CLI_MC_EQUIPMENT_V] AS
  
  
  
  
  
/******************************************************************    
* PROCEDURE : [cli].[CONOPS_CLI_MC_EQUIPMENT_V]  
* PURPOSE :   
* NOTES  :   
* CREATED : sxavier, 08 Aug 2023  
* SAMPLE :   
 1. SELECT * FROM [cli].[CONOPS_CLI_MC_EQUIPMENT_V]  
  
* MODIFIED DATE     AUTHOR   DESCRIPTION    
*------------------------------------------------------------------    
* {08 Aug 2023}  {sxavier}  {Initial Created}
* {13 Oct 2023}	 {lwasini}	{Change Drill source to Asset Efficiency}
*******************************************************************/  
  
  
CREATE VIEW [cli].[CONOPS_CLI_MC_EQUIPMENT_V]  
AS  
  
  
  
SELECT  
 'Truck' AS EquipmentType,  
 '0' AS EquipmentTypeCode,  
 FieldId AS EquipmentId  
FROM [cli].[pit_truck] WITH (NOLOCK)  
  
UNION ALL  
  
  
SELECT  
 'Shovel' AS EquipmentType,  
 '1' AS EquipmentTypeCode,  
 FieldId AS EquipmentId  
FROM [cli].[pit_excav] WITH (NOLOCK)  
  
  
UNION ALL  
/*
SELECT DISTINCT  
 'Drill' AS EquipmentType,  
 '2' AS EquipmentTypeCode,  
 LEFT(REPLACE(DRILL_ID, ' ',''), 2) + RIGHT('00' + RIGHT(REPLACE(DRILL_ID, ' ',''), 1), 2) AS EquipmentId  
FROM [dbo].[FR_DRILLING_SCORES] WITH (NOLOCK)  
WHERE [SITE_CODE] = 'CLI'  
*/

SELECT DISTINCT  
'Drill' AS EquipmentType,  
'2' AS EquipmentTypeCode,  
EQMT AS EquipmentId  
FROM cli.ASSET_EFFICIENCY WITH (NOLOCK)  
WHERE UnitType = 'Drill'  
  
UNION ALL  
  
SELECT DISTINCT  
 'Crusher' AS EquipmentType,  
 '3' AS EquipmentTypeCode,  
 FieldId AS EquipmentId  
FROM [cli].[SHIFT_LOC] WITH (NOLOCK)  
WHERE FieldId IN ('CRUSHER 1')  
  
UNION ALL  
  
SELECT  
 'Support' AS EquipmentType,  
 '4' AS EquipmentTypeCode,  
 FieldId AS EquipmentId  
FROM [cli].[pit_auxeqmt] WITH (NOLOCK)  
  
  
  
  
