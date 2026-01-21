
     
/******************************************************************    
* PROCEDURE : DBO.[UPSERT_CONOPS_FLEET_PIT_MACHINE_C]  
* PURPOSE : UPSERT [UPSERT_CONOPS_FLEET_PIT_MACHINE_C]  
* NOTES     :   
* CREATED : GGOSAL1  
* SAMPLE    : EXEC DBO.[UPSERT_CONOPS_FLEET_PIT_MACHINE_C] 'BAG' 
* MODIFIED DATE  AUTHOR    DESCRIPTION    
*------------------------------------------------------------------    
* {21 MAR 2024}  {GGOSAL1}  {INITIAL CREATED}      
* {22 OCT 2025}  {GGOSAL1}  {Remove Fleet EQ HOS}      
*******************************************************************/    
CREATE PROCEDURE [dbo].[UPSERT_CONOPS_FLEET_PIT_MACHINE_C]  
(  
@G_SITE  VARCHAR(5)  

)  
AS  
BEGIN  

DECLARE @G_SITE_ALIAS VARCHAR(5)

SET @G_SITE_ALIAS = CASE WHEN @G_SITE = 'CLI' THEN 'CMX' ELSE @G_SITE END  
    
IF @G_SITE = 'BAG'

EXEC (
'DELETE FROM ' +@G_SITE+ '.FLEET_PIT_MACHINE_C'
+' WHERE SHIFTINDEX = (SELECT SHIFTINDEX '
+'  FROM [DBO].[SHIFT_INFO_V]  '
+'  WHERE SITEFLAG = ''BAG'' AND SHIFTFLAG =''CURR'')'
  
+' INSERT INTO ' +@G_SITE+ '.FLEET_PIT_MACHINE_C' 
+' SELECT ' 
+' siteflag,' 
+' SHIFTID,'
+' SHIFTINDEX,'
+' EquipmentID,'
+' EquipmentCategory,'
+' EQMTTYPE,'
+' StatusCode,'
+' StatusStart,'
+' TimeInState,'
+' CrewName,'
+' Location,'
+' Region,'
+' Operator,'
+' OperatorId,'
+' AssignedShovel,'
+' FieldX,'
+' FieldY,'
+' FieldZ,'
+' FieldVelocity'      
+' FROM ' +@G_SITE+ '.FLEET_PIT_MACHINE_V'     
+' WHERE EquipmentID IS NOT NULL '


+'DELETE FROM ' +@G_SITE+ '.FLEET_PIT_MACHINE_C'
+' WHERE SHIFTINDEX < (SELECT SHIFTINDEX - 3 '
+'  FROM [DBO].[SHIFT_INFO_V]  '
+'  WHERE SITEFLAG = ''BAG'' AND SHIFTFLAG =''CURR'')'

);     

--EXEC DBO.[UPSERT_CONOPS_FLEET_EQUIPMENT_HOURLY_STATUS] 'BAG';

--Update Table Monitoring
UPDATE [dbo].[DI_JOB_CONTROL_ENTRY_TS_BASE]
SET dw_load_ts = GETUTCDATE()
WHERE job_name = 'job_conops_fleet_pit_machine_c'

END     



