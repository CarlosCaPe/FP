CREATE VIEW [saf].[CONOPS_SAF_MC_EQUIPMENT_V] AS
  
  
  
  
/******************************************************************    
* PROCEDURE : [saf].[CONOPS_SAF_MC_EQUIPMENT_V]  
* PURPOSE :   
* NOTES  :   
* CREATED : sxavier, 08 Aug 2023  
* SAMPLE :   
 1. SELECT * FROM [saf].[CONOPS_SAF_MC_EQUIPMENT_V]  
  
* MODIFIED DATE     AUTHOR   DESCRIPTION    
*------------------------------------------------------------------    
* {08 Aug 2023}  {sxavier}  {Initial Created}
* {13 Oct 2023}	 {lwasini}	{Change Drill source to Asset Efficiency}
*******************************************************************/  
  
CREATE VIEW [saf].[CONOPS_SAF_MC_EQUIPMENT_V]  
AS  
  
  
  
SELECT  
 'Truck' AS EquipmentType,  
 '0' AS EquipmentTypeCode,  
 FieldId AS EquipmentId  
FROM [saf].[pit_truck] WITH (NOLOCK)  
  
UNION ALL  
  
  
SELECT  
 'Shovel' AS EquipmentType,  
 '1' AS EquipmentTypeCode,  
 FieldId AS EquipmentId  
FROM [saf].[pit_excav] WITH (NOLOCK)  
  
  
UNION ALL  
/*
SELECT DISTINCT  
 'Drill' AS EquipmentType,  
 '2' AS EquipmentTypeCode,  
 'D' + RIGHT('000' + SUBSTRING(REPLACE(DRILL_ID, ' ',''),CHARINDEX('-',REPLACE(DRILL_ID, ' ',''))+1,LEN(REPLACE(DRILL_ID, ' ',''))), 3) AS EquipmentId  
FROM [dbo].[FR_DRILLING_SCORES] WITH (NOLOCK)  
WHERE [SITE_CODE] = 'SAF'  
*/

SELECT DISTINCT  
'Drill' AS EquipmentType,  
'2' AS EquipmentTypeCode,  
EQMT AS EquipmentId  
FROM saf.ASSET_EFFICIENCY WITH (NOLOCK)  
WHERE UnitType = 'Drill'  
  
UNION ALL  
  
SELECT DISTINCT  
 'Crusher' AS EquipmentType,  
 '3' AS EquipmentTypeCode,  
 FIELDID AS EquipmentId  
FROM [saf].[SHIFT_LOC] WITH (NOLOCK)  
WHERE FIELDID LIKE '%crusher%'   
  
  
UNION ALL  
  
SELECT  
 'Support' AS EquipmentType,  
 '4' AS EquipmentTypeCode,  
 FieldId AS EquipmentId  
FROM [saf].[pit_auxeqmt] WITH (NOLOCK)  
  
  
  
  
