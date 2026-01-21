CREATE VIEW [mor].[CONOPS_MOR_MC_EQUIPMENT_V] AS




/******************************************************************  
* PROCEDURE	: [mor].[CONOPS_MOR_MC_EQUIPMENT_V]
* PURPOSE	: 
* NOTES		: 
* CREATED	: lwasni, 08 Aug 2023
* SAMPLE	: 
	1. SELECT * FROM [mor].[CONOPS_MOR_MC_EQUIPMENT_V]

* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {08 Aug 2023}		{lwasni}		{Initial Created}
* {08 Aug 2023}		{sxavier}		{Add Equipment type code}
*******************************************************************/


CREATE VIEW [mor].[CONOPS_MOR_MC_EQUIPMENT_V]
AS



SELECT
	'Truck' AS EquipmentType,
	'0' AS EquipmentTypeCode,
	FieldId AS EquipmentId
FROM [mor].[pit_truck] WITH (NOLOCK)

UNION ALL


SELECT
	'Shovel' AS EquipmentType,
	'1' AS EquipmentTypeCode,
	FieldId AS EquipmentId
FROM [mor].[pit_excav] WITH (NOLOCK)


UNION ALL

SELECT DISTINCT
	'Drill' AS EquipmentType,
	'2' AS EquipmentTypeCode,
	REPLACE(DRILL_ID, ' ','') AS EquipmentId
FROM [dbo].[FR_DRILLING_SCORES] WITH (NOLOCK)
WHERE [SITE_CODE] = 'MOR'
AND DRILL_ID NOT IN ('30R', '31R')


UNION ALL

SELECT DISTINCT
	'Crusher' AS EquipmentType,
	'3' AS EquipmentTypeCode,
	CASE WHEN FieldId IN ( '849-MFL', 'C2MFL', 'C2MIL' ) THEN 'Crusher 2'
	WHEN FieldId IN ( '859-MILL', 'C3MFL', 'C3MIL' ) THEN 'Crusher 3' 
	END AS EquipmentId
FROM [mor].[SHIFT_LOC] WITH (NOLOCK)
WHERE FieldId IN ( 'C2MIL', 'C3MIL', 'C2MFL', 'C3MFL' )

UNION ALL

SELECT
	'Support' AS EquipmentType,
	'4' AS EquipmentTypeCode,
	FieldId AS EquipmentId
FROM [mor].[pit_auxeqmt] WITH (NOLOCK)



