



      
            
/******************************************************************              
* PROCEDURE : DBO.[UPSERT_CONOPS_PIT_LOC_C]            
* PURPOSE : UPSERT [UPSERT_CONOPS_PIT_LOC_C]            
* NOTES     :             
* CREATED : MFAHMI            
* SAMPLE    : EXEC DBO.[UPSERT_CONOPS_PIT_LOC_C]             
* MODIFIED DATE  AUTHOR    DESCRIPTION              
*------------------------------------------------------------------              
* {04 DEC 2022}  {MFAHMI}   {INITIAL CREATED}         
* {01 MAR 2023}  {GGOSAL1}  {ADD COLUMN SITEFLAG} 
* {23 DEC 2023}  {GGOSAL1}  {ADD NEW SITE: ABR & TYR}
*******************************************************************/              
CREATE  PROCEDURE [dbo].[UPSERT_CONOPS_PIT_LOC_C]            
(            
@G_SITE  VARCHAR(5)            
          
)            
AS            
BEGIN            

DECLARE @G_SITE_ALIAS VARCHAR(5)

SET @G_SITE_ALIAS = CASE WHEN @G_SITE = 'CLI' THEN 'CMX' ELSE @G_SITE END  
           
IF @G_SITE = 'MOR'          
          
EXEC (          
'DELETE FROM ' +@G_SITE+ '.PIT_LOC_C'          
+' WHERE SHIFTINDEX = (SELECT SHIFTINDEX '          
+'  FROM [DBO].[SHIFT_INFO_V]  '          
+'  WHERE SITEFLAG = ''MOR'' AND SHIFTFLAG =''CURR'')'          
            
+' INSERT INTO ' +@G_SITE+ '.PIT_LOC_C'           
+' SELECT '           
+' ''' +@G_SITE_ALIAS+ ''' AS SITEFLAG,' 
+' SHIFTINDEX,'          
+' SHIFTID,'          
+' DBPREVIOUS,'          
+' DBNEXT,'          
+' DBVERSION,'          
+' ID,'          
+' DBNAME,'          
+' DBKEY,'          
+' FIELDID,'          
+' FIELDPIT,'          
+' FIELDREGION,'          
+' FIELDBLENDREC,'          
+' FIELDPATH,'          
+' FIELDBEAN,'          
+' FIELDINVBEAN,'          
+' FIELDHAUL,'          
+' FIELDORE,'          
+' FIELDDUMPFEED,'          
+' FIELDDUMPCAPY,'          
+' FIELDBINSIZE,'          
+' FIELDXLOC,'          
+' FIELDYLOC,'          
+' FIELDPATHIX,'          
+' FIELDTIMEDUMP,'          
+' FIELDZLOC,'          
+' FIELDSIGNID,'          
+' FIELDUNIT,'          
+' FIELDLOAD,'          
+' FIELDISTIEDOWN,'          
+' FIELDSTATUS,'          
+' FIELDLINESTAT,'          
+' FIELDSPILLAGE,'          
+' FIELDSIGNPOST,'          
+' FIELDSHOPTYPE,'          
+' FIELDDUMPQUEUE,'          
+' FIELDPCTCAPY,'          
+' FIELDBAYS,'          
+' FIELDNOPENALTY,'          
+' FIELDTIMELAST,'          
+' FIELDRADIUS,'          
+' FIELDGPSTYPE,'          
+' FIELDREASON,'          
+' FIELDIVTREC,'          
+' FIELDTDSET,'          
+' FIELDPRIOR,'          
+' FIELDAVAILBAYS,'          
+' FIELDPARKQUEUE,'          
+' FIELDLASTSTATTIME,'          
+' FIELDBCNTIME,'          
+' FIELDTAGDATE,'          
+' FIELDTAGEQMT,'          
+' FIELDTRUCKSENROUTE,'          
+' FIELDLASTASSIGN,'          
+' FIELDLASTARRIVE,'          
+' FIELDSPEEDTRAP,'          
+' FIELDLVSPROXCNT,'          
+' FIELDIGNUNEXARR,'          
+' FIELDMETADATA,'          
+' FIELDDISABLEARRCHK,'          
+' FIELDINTF_DATA1,'          
+' FIELDINTF_DATA2,'          
+' FIELDINTF_DATA3,'          
+' UTC_CREATED_DATE,'          
+' UTC_LOGICAL_DELETED_DATE'          
+' FROM ' +@G_SITE+ '.PIT_LOC A'          
+' LEFT OUTER JOIN [DBO].[SHIFT_INFO_V] B '          
+' ON B.SITEFLAG= ''MOR'' AND B.SHIFTFLAG = ''CURR'''          
+' WHERE A.ID IS NOT NULL '          
          
          
+'DELETE FROM ' +@G_SITE+ '.PIT_LOC_C'          
+' WHERE SHIFTINDEX < (SELECT SHIFTINDEX - 3 '          
+'  FROM [DBO].[SHIFT_INFO_V]  '          
+'  WHERE SITEFLAG = ''MOR'' AND SHIFTFLAG =''CURR'')'          
          
);          
    
IF @G_SITE = 'BAG'          
          
EXEC (          
'DELETE FROM ' +@G_SITE+ '.PIT_LOC_C'          
+' WHERE SHIFTINDEX = (SELECT SHIFTINDEX '          
+'  FROM [DBO].[SHIFT_INFO_V]  '          
+'  WHERE SITEFLAG = ''BAG'' AND SH