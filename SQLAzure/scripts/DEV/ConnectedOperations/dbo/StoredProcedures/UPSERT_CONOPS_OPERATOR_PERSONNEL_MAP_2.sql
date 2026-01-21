
/******************************************************************  
* PROCEDURE : dbo.[UPSERT_CONOPS_OPERATOR_PERSONNEL_MAP_2]
* PURPOSE	: Upsert [UPSERT_CONOPS_OPERATOR_PERSONNEL_MAP_2]
* NOTES     : 
* CREATED	: ggosal1
* SAMPLE    : EXEC dbo.[UPSERT_CONOPS_OPERATOR_PERSONNEL_MAP_2] 
* MODIFIED DATE		AUTHOR				DESCRIPTION  
*------------------------------------------------------------------  
* {08 FEB 2023}		{ggosal1}			{Initial Created}  
* {20 FEB 2023}		{ggosal1}			{Expand for all sites}  
*******************************************************************/  
CREATE PROCEDURE [dbo].[UPSERT_CONOPS_OPERATOR_PERSONNEL_MAP_2]
AS
BEGIN

DELETE FROM dbo.operator_personnel_map_2

INSERT INTO dbo.operator_personnel_map_2
SELECT 
SITE_CODE
,SHIFTINDEX
,OPERATOR_ID
,PERSONNEL_ID
,CREW
,FULL_NAME
,FIRST_NAME
,LAST_NAME
,FIRST_LAST_NAME
,UTC_CREATED_DATE
,TRY_CONVERT([numeric],[OPERATOR_ID]) AS OperatorID_Num
 FROM dbo.operator_personnel_map_stg_2 
 
END



