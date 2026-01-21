CREATE VIEW [SIE].[CONOPS_SIE_MC_EQUIPMENT_V] AS

  
  
  
/******************************************************************    
* PROCEDURE : [sie].CONOPS_SIE_MC_EQUIPMENT_V  
* PURPOSE :   
* NOTES  :   
* CREATED : lwasni, 08 Aug 2023  
* SAMPLE :   
 1. SELECT * FROM [sie].[CONOPS_SIE_MC_EQUIPMENT_V]  
  
* MODIFIED DATE     AUTHOR   DESCRIPTION    
*------------------------------------------------------------------    
* {08 Aug 2023}  {lwasini}  {Initial Created}  
* {08 Aug 2023}  {sxavier}  {Add Equipment type code}  
* {18 Oct 2023}  {lwasini}  {Exclude Drill from Support Equipment}  
* {13 Oct 2023}  {lwasini}  {Change Drill source to Asset Efficiency}  
* {05 Jan 2024}  {lwasini}  {Modify Crusher}  
*******************************************************************/  
  
  
CREATE VIEW [sie].[CONOPS_SIE_MC_EQUIPMENT_V]  
AS  
  
  
SELECT  
 'Truck' AS EquipmentType,  
 '0' AS EquipmentTypeCode,  
 FieldId AS EquipmentId  
FROM [sie].[pit_truck] WITH (NOLOCK)  
  
UNION ALL  
  
  
SELECT  
 'Shovel' AS EquipmentType,  
 '1' AS EquipmentTypeCode,  
 FieldId AS EquipmentId  
FROM [sie].[pit_excav] WITH (NOLOCK)  
  
  
UNION ALL  
/*  
SELECT DISTINCT  
 'Drill' AS EquipmentType,  
 '2' AS EquipmentTypeCode,  
 'DR' + RIGHT(REPLACE(DRILL_ID, ' ',''), 2) AS EquipmentId  
FROM [dbo].[FR_DRILLING_SCORES] WITH (NOLOCK)  
WHERE [SITE_CODE] = 'SIE'  
AND 'DR' + RIGHT(REPLACE(DRILL_ID, ' ',''), 2) <> 'DR81'  
*/  
  
SELECT DISTINCT  
'Drill' AS EquipmentType,  
'2' AS EquipmentTypeCode,  
EQMT AS EquipmentId  
FROM sie.ASSET_EFFICIENCY WITH (NOLOCK)  
WHERE UnitType = 'Drill'  
  
  
UNION ALL  
  
SELECT DISTINCT  
 'Crusher' AS EquipmentType,  
 '3' AS EquipmentTypeCode,  
 --CASE WHEN FieldId IN ('CR13909O', 'A-SIDE', 'B-SIDE') THEN 'Crusher'   
 CASE WHEN FieldId IN ('CR13909O') THEN 'SECONDARIES'   
 ELSE FieldId END AS EquipmentId
FROM [sie].[SHIFT_LOC] WITH (NOLOCK)  
WHERE FieldId IN ('CR13909O', 'A-SIDE', 'B-SIDE')  

UNION ALL  
  
SELECT  
EquipmentType,  
EquipmentTypeCode,  
EquipmentId  
FROM (  
SELECT  
 'Support' AS EquipmentType,  
 '4' AS EquipmentTypeCode,  
 FieldId AS EquipmentId  
FROM [sie].[pit_auxeqmt] WITH (NOLOCK)  
  
EXCEPT  
  
SELECT  
'Support' AS EquipmentType,  
'4' AS EquipmentTypeCode,  
REPLACE([EQUIPMENTNUMBER], ' ','') AS EquipmentId    
FROM [SIE].[DRILL_UTILIZATION] WITH (NOLOCK)) Suppt  
  
  
  
  
