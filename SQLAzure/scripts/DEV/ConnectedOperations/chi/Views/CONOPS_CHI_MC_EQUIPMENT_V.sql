CREATE VIEW [chi].[CONOPS_CHI_MC_EQUIPMENT_V] AS

  
  
  
  
  
/******************************************************************    
* PROCEDURE : [chi].[CONOPS_CHI_MC_EQUIPMENT_V]  
* PURPOSE :   
* NOTES  :   
* CREATED : sxavier, 08 Aug 2023  
* SAMPLE :   
 1. SELECT * FROM [chi].[CONOPS_CHI_MC_EQUIPMENT_V]  
  
* MODIFIED DATE     AUTHOR   DESCRIPTION    
*------------------------------------------------------------------    
* {08 Aug 2023}  {sxavier}  {Initial Created}  
* {13 Oct 2023}  {lwasini}	{Change Drill source to Asset Efficiency}
*******************************************************************/  
  
  
CREATE VIEW [chi].[CONOPS_CHI_MC_EQUIPMENT_V]  
AS  
  
  
  
SELECT  
 'Truck' AS EquipmentType,  
 '0' AS EquipmentTypeCode,  
 FieldId AS EquipmentId  
FROM [chi].[pit_truck] WITH (NOLOCK) 
WHERE FieldId NOT IN ('897','898') 
  
UNION ALL  
  
  
SELECT  
 'Shovel' AS EquipmentType,  
 '1' AS EquipmentTypeCode,  
 FieldId AS EquipmentId  
FROM [chi].[pit_excav] WITH (NOLOCK)  
  
  
UNION ALL  
/*
SELECT DISTINCT  
 'Drill' AS EquipmentType,  
 '2' AS EquipmentTypeCode,  
 'DRL' + LEFT(REPLACE(DRILL_ID, ' ',''), 2) AS EquipmentId  
FROM [dbo].[FR_DRILLING_SCORES] WITH (NOLOCK)  
WHERE [SITE_CODE] = 'CHI'  
*/

SELECT DISTINCT  
'Drill' AS EquipmentType,  
'2' AS EquipmentTypeCode,  
EQMT AS EquipmentId  
FROM chi.ASSET_EFFICIENCY WITH (NOLOCK)  
WHERE UnitType = 'Drill'  
  
UNION ALL  
  
SELECT DISTINCT  
 'Crusher' AS EquipmentType,  
 '3' AS EquipmentTypeCode,  
 FieldId AS EquipmentId  
FROM [chi].[SHIFT_LOC] WITH (NOLOCK)  
WHERE FieldId = 'CRUSHER'  
  
  
UNION ALL  
  
SELECT  
 'Support' AS EquipmentType,  
 '4' AS EquipmentTypeCode,  
 FieldId AS EquipmentId  
FROM [chi].[pit_auxeqmt] WITH (NOLOCK)  
  
  
  
  

