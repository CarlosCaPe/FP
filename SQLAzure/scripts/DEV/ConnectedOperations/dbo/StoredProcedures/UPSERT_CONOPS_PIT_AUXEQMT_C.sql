



            
/******************************************************************              
* PROCEDURE : DBO.[UPSERT_CONOPS_PIT_AUXEQMT_C]            
* PURPOSE : UPSERT [UPSERT_CONOPS_PIT_AUXEQMT_C]            
* NOTES     :             
* CREATED : MFAHMI            
* SAMPLE    : EXEC DBO.[UPSERT_CONOPS_PIT_AUXEQMT_C] 'mor'            
* MODIFIED DATE  AUTHOR    DESCRIPTION              
*------------------------------------------------------------------              
* {23 FEB 2023}  {MFAHMI}   {INITIAL CREATED}     
* {01 MAR 2023}  {GGOSAL1}  {ADD COLUMN SITEFLAG}       
* {28 DEC 2023}  {GGOSAL1}  {ADD NEW SITE: ABR & TYR}  
*******************************************************************/              
CREATE  PROCEDURE [dbo].[UPSERT_CONOPS_PIT_AUXEQMT_C]            
(            
@G_SITE  VARCHAR(5)            
          
)            
AS            
BEGIN            
 
DECLARE @G_SITE_ALIAS VARCHAR(5)

SET @G_SITE_ALIAS = CASE WHEN @G_SITE = 'CLI' THEN 'CMX' ELSE @G_SITE END  
                  
IF @G_SITE = 'MOR'          
          
EXEC (          
'DELETE FROM ' +@G_SITE+ '.PIT_AUXEQMT_C'          
+' WHERE SHIFTINDEX = (SELECT SHIFTINDEX '          
+'  FROM [DBO].[SHIFT_INFO_V]  '          
+'  WHERE SITEFLAG = ''MOR'' AND SHIFTFLAG =''CURR'')'          
            
+' INSERT INTO ' +@G_SITE+ '.PIT_AUXEQMT_C'           
+' SELECT '      
+' ''' +@G_SITE_ALIAS+ ''' AS SITEFLAG,'        
+' B.SHIFTINDEX,'          
+' B.SHIFTID,'          
+' DbPrevious, '
+' DbNext, '
+' DbVersion, '
+' Id, '
+' DbName, '
+' DbKey, '
+' FieldId, '
+' FieldLoc, '
+' FieldExcav, '
+' FieldAux, '
+' FieldVan, '
+' FieldReglock, '
+' FieldBaysplit, '
+' FieldSendcount, '
+' FieldRcvcount, '
+' FieldTimelate, '
+' FieldClock, '
+' FieldTimeassign, '
+' FieldTimelast, '
+' FieldTimenext, '
+' FieldPanelid, '
+' FieldLinereason, '
+' FieldReason, '
+' FieldUnit, '
+' FieldUnitloc, '
+' FieldStatus, '
+' FieldLogin, '
+' FieldPort, '
+' FieldLinestat, '
+' FieldEqmttype, '
+' FieldComment, '
+' FieldLinecmt, '
+' FieldActsim, '
+' FieldActlast, '
+' FieldVsmstbl, '
+' FieldXloc, '
+' FieldYloc, '
+' FieldRadius, '
+' FieldVelocity, '
+' FieldHeading, '
+' FieldDirection, '
+' FieldTiedownaccepted, '
+' FieldZ, '
+' FieldLaststatustime, '
+' FieldLaststatreason, '
+' FieldTiedownproposed, '
+' FieldLastbreak, '
+' FieldCuroper, '
+' FieldCurscope, '
+' FieldCurbreak, '
+' FieldFsgroup, '
+' FieldHpgps, '
+' FieldPv3sup, '
+' FieldLastrftagtime, '
+' FieldPrestartdone, '
+' FieldPresunit, '
+' FieldLvsproxcnt, '
+' FieldLastgpsupdate, '
+' FieldGpsok, '
+' FieldFueltank, '
+' FieldFuelremain, '
+' FieldLastfuelcalc, '
+' FieldFueltime, '
+' FieldFuelfact, '
+' FieldOemfueltime, '
+' FieldHdwtype, '
+' FieldVansize, '
+' FieldVanoccupied, '
+' FieldMaintdate, '
+' FieldLastservicedate, '
+' FieldMainthours, '
+' FieldEnghr, '
+' FieldEnghrtime, '
+' FieldEqreq, '
+' FieldTanksize, '
+' FieldTankremain, '
+' FieldSpray, '
+' FieldGrade, '
+' FieldAuxsched, '
+' FieldAuxtask, '
+' FieldLocnext, '
+' FieldLoclast, '
+' FieldExpected, '
+' FieldActnext, '
+' FieldPmid, '
+' FieldTdbar, '
+' FieldTdrelease, '
+' FieldDevver, '
+' FieldDevhw, '
+' FieldDevbc, '
+' FieldDevop, '
+' FieldRuntime, '
+' FieldFuelenghr, '
+' FieldIntf_data, '
+' FieldRulelasttime, '
+' UTC_CREATED_DATE  '         
+' FROM ' +@G_SITE+ '.PIT_AUXEQMT A'          
+' LEFT OUTER JOIN [DBO].[SHIFT_INFO_V] B '          
+' ON B.SITEFLAG= ''MOR'' AND B.SHIFTFLAG = ''CURR'''          
+' WHERE A.ID IS NOT NULL '          
          
          
+'DELETE FROM ' +@G_SITE+ '.PIT_AUXEQMT_C'          
+' WHERE SHIFTINDEX < (SELECT SHIFTINDEX - 3 '          
+'  FROM [DBO].[SHIFT_INFO_V]  '          
+'  WHERE SITEFLAG = ''MOR'' AND SHIFTFLAG =''CURR'')'          
          
);          
          
          
IF @G_SITE =