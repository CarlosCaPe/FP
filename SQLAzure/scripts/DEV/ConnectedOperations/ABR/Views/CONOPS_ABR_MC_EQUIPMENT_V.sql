CREATE VIEW [ABR].[CONOPS_ABR_MC_EQUIPMENT_V] AS

  
  
  
  
  
/******************************************************************    
* PROCEDURE : [abr].[CONOPS_ABR_MC_EQUIPMENT_V]  
* PURPOSE :   
* NOTES  :   
* CREATED : lwasini, 12 Jan 2024
* SAMPLE :   
 1. SELECT * FROM [abr].[CONOPS_ABR_MC_EQUIPMENT_V]  
  
* MODIFIED DATE     AUTHOR   DESCRIPTION    
*------------------------------------------------------------------    
* {12 Jan 2024}  {lwasini}  {Initial Created}  
*******************************************************************/  
  
  
CREATE VIEW [abr].[CONOPS_ABR_MC_EQUIPMENT_V]  
AS  
  
  
  
SELECT  
 'Truck' AS EquipmentType,  
 '0' AS EquipmentTypeCode,  
 FieldId AS EquipmentId  
FROM [abr].[pit_truck] WITH (NOLOCK)  
  
UNION ALL  
  
  
SELECT  
 'Shovel' AS EquipmentType,  
 '1' AS EquipmentTypeCode,  
 FieldId AS EquipmentId  
FROM [abr].[pit_excav] WITH (NOLOCK)  
  
  
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
EQMT AS EquipmentId  
FROM bag.ASSET_EFFICIENCY WITH (NOLOCK)  
WHERE UnitType = 'Drill'  
  
  
UNION ALL  
  
SELECT DISTINCT  
 'Crusher' AS EquipmentType,  
 '3' AS EquipmentTypeCode,  
 FieldId AS EquipmentId  
FROM [abr].[SHIFT_LOC] WITH (NOLOCK)  
WHERE FieldId ='Crusher 1'
  
  
UNION ALL  
  
SELECT  
 'Support' AS EquipmentType,  
 '4' AS EquipmentTypeCode,  
 FieldId AS EquipmentId  
FROM [abr].[pit_auxeqmt] WITH (NOLOCK)  
  
  
  
  
