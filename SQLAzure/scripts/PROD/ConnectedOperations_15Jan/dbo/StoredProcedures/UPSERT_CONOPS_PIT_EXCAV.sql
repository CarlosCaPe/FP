

      
        
/******************************************************************      
* PROCEDURE : dbo.[UPSERT_CONOPS_PIT_EXCAV]    
* PURPOSE : Upsert [UPSERT_CONOPS_PIT_EXCAV]    
* NOTES     :     
* CREATED : lwasini    
* SAMPLE    : EXEC dbo.[UPSERT_CONOPS_PIT_EXCAV]     
* MODIFIED DATE  AUTHOR    DESCRIPTION      
*------------------------------------------------------------------      
* {25 OCT 2022}  {lwasini}   {Initial Created}      
*******************************************************************/      
CREATE  PROCEDURE [dbo].[UPSERT_CONOPS_PIT_EXCAV]    
(    
@G_SITE VARCHAR(5)    
)    
AS    
BEGIN    
EXEC     
(  
' DELETE FROM ' +@G_SITE+ '.pit_excav'     
    
+' INSERT INTO ' +@G_SITE+ '.pit_excav'     
+' SELECT '     
+'  DbPrevious'     
+' ,DbNext'     
+' ,DbVersion'     
+' ,Id'     
+' ,DbName'     
+' ,DbKey'     
+' ,FieldId'     
+' ,FieldQueue'     
+' ,FieldExcavnext'     
+' ,FieldLoc'     
+' ,FieldLocnext'     
+' ,FieldExcavlock'     
+' ,FieldDumplock'     
+' ,FieldExcav'     
+' ,FieldDumpasn'     
+' ,FieldLocstart'     
+' ,FieldLastloc'     
+' ,FieldVan'     
+' ,FieldRegionlock'     
+' ,FieldLastexcav'     
+' ,FieldBay'     
+' ,FieldLunchbreak'     
+' ,FieldBean'     
+' ,FieldSize'     
+' ,FieldFuelamt'     
+' ,FieldTons'     
+' ,FieldSimcode'     
+' ,FieldSendcount'     
+' ,FieldRcvcount'     
+' ,FieldTime1'     
+' ,FieldTime2'     
+' ,FieldBeans'     
+' ,FieldTimelate'     
+' ,FieldTimelast'     
+' ,FieldTimenext'     
+' ,FieldRateload'     
+' ,FieldTimespot'     
+' ,FieldClock'     
+' ,FieldAsntime'     
+' ,FieldTimebreak'     
+' ,FieldTimepanel'     
+' ,FieldCalctime'     
+' ,FieldMaxrateload'     
+' ,FieldPanelid'     
+' ,FieldFueltank'     
+' ,FieldSignid'     
+' ,FieldReason'     
+' ,FieldLinereason'     
+' ,FieldUnit'     
+' ,FieldUnitloc'     
+' ,FieldUnitlocnext'     
+' ,FieldActlast'     
+' ,FieldActnext'     
+' ,FieldActsim'     
+' ,FieldStatus'     
+' ,FieldLoad'     
+' ,FieldPort'     
+' ,FieldPrior'     
+' ,FieldLinestat'     
+' ,FieldLogin'     
+' ,FieldPriorore'     
+' ,FieldPriorwaste'     
+' ,FieldRetorque'     
+' ,FieldEqmttype'     
+' ,FieldNoassign'     
+' ,FieldTram'     
+' ,FieldLastload'     
+' ,FieldSignpost'     
+' ,FieldDoublespot'     
+' ,FieldVsmstbl'     
+' ,FieldComment'     
+' ,FieldLinecmt'     
+' ,FieldIrbeacon'     
+' ,FieldTramload'     
+' ,FieldFreearrive'     
+' ,FieldSaveprior'     
+' ,FieldDist'     
+' ,FieldEfh'     
+' ,FieldXloc'     
+' ,FieldYloc'     
+' ,FieldRadius'     
+' ,FieldGpstype'     
+' ,FieldLpeqmt'     
+' ,FieldTramschedule'     
+' ,FieldDiglock'     
+' ,FieldVelocity'     
+' ,FieldHeading'     
+' ,FieldDirection'     
+' ,FieldTiedownaccepted'     
+' ,FieldPropfeed'     
+' ,FieldZ'     
+' ,FieldShoveldist'     
+' ,FieldDumpdist'     
+' ,FieldLaststatustime'     
+' ,FieldLaststatreason'     
+' ,FieldTiedownproposed'     
+' ,FieldThreshold'     
+' ,FieldMinout'     
+' ,FieldTiretime'     
+' ,FieldTirectrl'     
+' ,FieldDumpasntime'     
+' ,FieldShovelfulltime'     
+' ,FieldLastbreak'     
+' ,FieldCuroper'     
+' ,FieldCurscope'     
+' ,FieldCurbreak'     
+' ,FieldOrigasnexcav'     
+' ,FieldOrigasnloc'     
+' ,FieldReasnby'     
+' ,FieldPathtime'     
+' ,FieldQueuesize'     
+' ,FieldTimequeue'     
+' ,FieldPantoready'     
+' ,FieldExptraveldist'     
+' ,FieldExptraveltime'     
+' ,FieldGpstraveldist'     
+' ,FieldFsgroup'     
+' ,FieldGloc'     
+' ,FieldHpgps'     
+' ,FieldPv3sup'     
+' ,FieldLastrftagtime'     
+' ,FieldActpoly'     
+' ,FieldPrestartdone'     
+' ,FieldPresunit'     
+' ,FieldPandh'     
+' ,FieldFirstdipper'     
+' ,FieldLastdipper'     
+' ,FieldBktcnt'     
+' ,FieldCnt'     
+' ,FieldPantoid'     
+' ,FieldPantouploc'     
+' ,FieldPantoup