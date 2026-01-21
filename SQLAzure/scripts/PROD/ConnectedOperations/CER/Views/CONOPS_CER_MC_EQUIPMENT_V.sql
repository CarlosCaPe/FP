CREATE VIEW [CER].[CONOPS_CER_MC_EQUIPMENT_V] AS





/******************************************************************  
* PROCEDURE	: [cer].[CONOPS_CER_MC_EQUIPMENT_V]
* PURPOSE	: 
* NOTES		: 
* CREATED	: sxavier, 08 Aug 2023
* SAMPLE	: 
	1. SELECT * FROM [cer].[CONOPS_CER_MC_EQUIPMENT_V]

* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {08 Aug 2023}		{sxavier}		{Initial Created}
*******************************************************************/


CREATE VIEW [cer].[CONOPS_CER_MC_EQUIPMENT_V]
AS



SELECT
	'Truck' AS EquipmentType,
	'0' AS EquipmentTypeCode,
	FieldId AS EquipmentId
FROM [cer].[pit_truck] WITH (NOLOCK)

UNION ALL


SELECT
	'Shovel' AS EquipmentType,
	'1' AS EquipmentTypeCode,
	FieldId AS EquipmentId
FROM [cer].[pit_excav] WITH (NOLOCK)


UNION ALL

SELECT DISTINCT
	'Drill' AS EquipmentType,
	'2' AS EquipmentTypeCode,
	REPLACE(DRILL_ID, ' ','') AS EquipmentId
FROM [dbo].[FR_DRILLING_SCORES] WITH (NOLOCK)
WHERE [SITE_CODE] = 'CER'


UNION ALL

SELECT DISTINCT
	'Crusher' AS EquipmentType,
	'3' AS EquipmentTypeCode,
	FieldId AS EquipmentId
FROM [cer].[SHIFT_LOC] WITH (NOLOCK)
WHERE FieldId in ('MILLCHAN','MILLCRUSH1','MILLCRUSH2','HIDROCHAN')


UNION ALL

SELECT
	'Support' AS EquipmentType,
	'4' AS EquipmentTypeCode,
	FieldId AS EquipmentId
FROM [cer].[pit_auxeqmt] WITH (NOLOCK)




