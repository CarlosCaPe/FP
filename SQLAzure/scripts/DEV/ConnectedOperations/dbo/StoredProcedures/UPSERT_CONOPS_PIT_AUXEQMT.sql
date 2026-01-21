


      
        
/******************************************************************      
* PROCEDURE : dbo.[UPSERT_CONOPS_PIT_AUXEQMT]    
* PURPOSE : Upsert [UPSERT_CONOPS_PIT_AUXEQMT]    
* NOTES     :     
* CREATED : mfahmi    
* SAMPLE    : EXEC dbo.[UPSERT_CONOPS_PIT_AUXEQMT] 'mor'    
* MODIFIED DATE  AUTHOR    DESCRIPTION      
*------------------------------------------------------------------      
* {23 FEB 2023}  {mfahmi}   {Initial Created}      
*******************************************************************/      
CREATE  PROCEDURE [dbo].[UPSERT_CONOPS_PIT_AUXEQMT]    
(    
@G_SITE VARCHAR(5)    
)    
AS    
BEGIN    
EXEC     
(  
' DELETE FROM ' +@G_SITE+ '.PIT_AUXEQMT'     
    
+' INSERT INTO ' +@G_SITE+ '.PIT_AUXEQMT'     
+' SELECT '     
+' DbPrevious '
+' ,DbNext '
+' ,DbVersion '
+' ,Id '
+' ,DbName '
+' ,DbKey '
+' ,FieldId '
+' ,FieldLoc '
+' ,FieldExcav '
+' ,FieldAux '
+' ,FieldVan '
+' ,FieldReglock '
+' ,FieldBaysplit '
+' ,FieldSendcount '
+' ,FieldRcvcount '
+' ,FieldTimelate '
+' ,FieldClock '
+' ,FieldTimeassign '
+' ,FieldTimelast '
+' ,FieldTimenext '
+' ,FieldPanelid '
+' ,FieldLinereason '
+' ,FieldReason '
+' ,FieldUnit '
+' ,FieldUnitloc '
+' ,FieldStatus '
+' ,FieldLogin '
+' ,FieldPort '
+' ,FieldLinestat '
+' ,FieldEqmttype '
+' ,FieldComment '
+' ,FieldLinecmt '
+' ,FieldActsim '
+' ,FieldActlast '
+' ,FieldVsmstbl '
+' ,FieldXloc '
+' ,FieldYloc '
+' ,FieldRadius '
+' ,FieldVelocity '
+' ,FieldHeading '
+' ,FieldDirection '
+' ,FieldTiedownaccepted '
+' ,FieldZ '
+' ,FieldLaststatustime '
+' ,FieldLaststatreason '
+' ,FieldTiedownproposed '
+' ,FieldLastbreak '
+' ,FieldCuroper '
+' ,FieldCurscope '
+' ,FieldCurbreak '
+' ,FieldFsgroup '
+' ,FieldHpgps '
+' ,FieldPv3sup '
+' ,FieldLastrftagtime '
+' ,FieldPrestartdone '
+' ,FieldPresunit '
+' ,FieldLvsproxcnt '
+' ,FieldLastgpsupdate '
+' ,FieldGpsok '
+' ,FieldFueltank '
+' ,FieldFuelremain '
+' ,FieldLastfuelcalc '
+' ,FieldFueltime '
+' ,FieldFuelfact '
+' ,FieldOemfueltime '
+' ,FieldHdwtype '
+' ,FieldVansize '
+' ,FieldVanoccupied '
+' ,FieldMaintdate '
+' ,FieldLastservicedate '
+' ,FieldMainthours '
+' ,FieldEnghr '
+' ,FieldEnghrtime '
+' ,FieldEqreq '
+' ,FieldTanksize '
+' ,FieldTankremain '
+' ,FieldSpray '
+' ,FieldGrade '
+' ,FieldAuxsched '
+' ,FieldAuxtask '
+' ,FieldLocnext '
+' ,FieldLoclast '
+' ,FieldExpected '
+' ,FieldActnext '
+' ,FieldPmid '
+' ,FieldTdbar '
+' ,FieldTdrelease '
+' ,FieldDevver '
+' ,FieldDevhw '
+' ,FieldDevbc '
+' ,FieldDevop '
+' ,FieldRuntime '
+' ,FieldFuelenghr '
+' ,FieldIntf_data '
+' ,FieldRulelasttime '
+' ,UTC_CREATED_DATE ' 
+' FROM ' +@G_SITE+ '.PIT_AUXEQMT_STG'  
    
 );    
END    

