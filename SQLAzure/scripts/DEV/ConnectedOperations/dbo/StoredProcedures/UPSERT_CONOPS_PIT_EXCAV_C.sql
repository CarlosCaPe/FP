


            
/******************************************************************              
* PROCEDURE : DBO.[UPSERT_CONOPS_PIT_EXCAV_C]            
* PURPOSE : UPSERT [UPSERT_CONOPS_PIT_EXCAV_C]            
* NOTES     :             
* CREATED : MFAHMI            
* SAMPLE    : EXEC DBO.[UPSERT_CONOPS_PIT_EXCAV_C]             
* MODIFIED DATE  AUTHOR    DESCRIPTION              
*------------------------------------------------------------------              
* {04 DEC 2022}  {MFAHMI}   {INITIAL CREATED}      
* {01 MAR 2023}  {GGOSAL1}  {ADD COLUMN SITEFLAG}  
* {23 DEC 2023}  {GGOSAL1}  {ADD NEW SITE: ABR & TYR}
*******************************************************************/              
CREATE  PROCEDURE [dbo].[UPSERT_CONOPS_PIT_EXCAV_C]            
(            
@G_SITE  VARCHAR(5)            
          
)            
AS            
BEGIN   
DECLARE @G_SITE_ALIAS VARCHAR(5)

SET @G_SITE_ALIAS = CASE WHEN @G_SITE = 'CLI' THEN 'CMX' ELSE @G_SITE END         
           
IF @G_SITE = 'MOR'          
          
EXEC (          
'DELETE FROM ' +@G_SITE+ '.PIT_EXCAV_C'          
+' WHERE SHIFTINDEX = (SELECT SHIFTINDEX '          
+'  FROM [DBO].[SHIFT_INFO_V]  '          
+'  WHERE SITEFLAG = ''MOR'' AND SHIFTFLAG =''CURR'')'          
            
+' INSERT INTO ' +@G_SITE+ '.PIT_EXCAV_C'           
+' SELECT '           
+' ''' +@G_SITE_ALIAS+ ''' AS SITEFLAG,' 
+' B.SHIFTINDEX,'          
+' B.SHIFTID,'          
+' DBPREVIOUS,'          
+' DBNEXT,'          
+' DBVERSION,'          
+' ID,'          
+' DBNAME,'          
+' DBKEY,'          
+' FIELDID,'          
+' FIELDQUEUE,'          
+' FIELDEXCAVNEXT,'          
+' FIELDLOC,'          
+' FIELDLOCNEXT,'          
+' FIELDEXCAVLOCK,'          
+' FIELDDUMPLOCK,'          
+' FIELDEXCAV,'          
+' FIELDDUMPASN,'          
+' FIELDLOCSTART,'          
+' FIELDLASTLOC,'          
+' FIELDVAN,'          
+' FIELDREGIONLOCK,'          
+' FIELDLASTEXCAV,'          
+' FIELDBAY,'          
+' FIELDLUNCHBREAK,'          
+' FIELDBEAN,'          
+' FIELDSIZE,'          
+' FIELDFUELAMT,'          
+' FIELDTONS,'          
+' FIELDSIMCODE,'          
+' FIELDSENDCOUNT,'          
+' FIELDRCVCOUNT,'          
+' FIELDTIME1,'          
+' FIELDTIME2,'          
+' FIELDBEANS,'          
+' FIELDTIMELATE,'          
+' FIELDTIMELAST,'          
+' FIELDTIMENEXT,'          
+' FIELDRATELOAD,'          
+' FIELDTIMESPOT,'          
+' FIELDCLOCK,'          
+' FIELDASNTIME,'          
+' FIELDTIMEBREAK,'          
+' FIELDTIMEPANEL,'          
+' FIELDCALCTIME,'          
+' FIELDMAXRATELOAD,'          
+' FIELDPANELID,'          
+' FIELDFUELTANK,'          
+' FIELDSIGNID,'          
+' FIELDREASON,'          
+' FIELDLINEREASON,'          
+' FIELDUNIT,'          
+' FIELDUNITLOC,'          
+' FIELDUNITLOCNEXT,'          
+' FIELDACTLAST,'          
+' FIELDACTNEXT,'          
+' FIELDACTSIM,'          
+' FIELDSTATUS,'          
+' FIELDLOAD,'          
+' FIELDPORT,'          
+' FIELDPRIOR,'          
+' FIELDLINESTAT,'          
+' FIELDLOGIN,'          
+' FIELDPRIORORE,'          
+' FIELDPRIORWASTE,'          
+' FIELDRETORQUE,'          
+' FIELDEQMTTYPE,'          
+' FIELDNOASSIGN,'          
+' FIELDTRAM,'          
+' FIELDLASTLOAD,'          
+' FIELDSIGNPOST,'          
+' FIELDDOUBLESPOT,'          
+' FIELDVSMSTBL,'          
+' FIELDCOMMENT,'          
+' FIELDLINECMT,'          
+' FIELDIRBEACON,'          
+' FIELDTRAMLOAD,'          
+' FIELDFREEARRIVE,'          
+' FIELDSAVEPRIOR,'          
+' FIELDDIST,'          
+' FIELDEFH,'          
+' FIELDXLOC,'          
+' FIELDYLOC,'          
+' FIELDRADIUS,'          
+' FIELDGPSTYPE,'          
+' FIELDLPEQMT,'          
+' FIELDTRAMSCHEDULE,'          
+' FIELDDIGLOCK,'          
+' FIELDVELOCITY,'          
+' FIELDHEADING,'          
+' FIELDDIRECTION,'       