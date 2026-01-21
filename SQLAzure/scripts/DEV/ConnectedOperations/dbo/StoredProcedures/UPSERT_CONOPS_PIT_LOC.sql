
   
/******************************************************************      
* PROCEDURE : DBO.[UPSERT_CONOPS_PIT_LOC]    
* PURPOSE : UPSERT [UPSERT_CONOPS_PIT_LOC]    
* NOTES     :     
* CREATED : LWASINI    
* SAMPLE    : EXEC DBO.[UPSERT_CONOPS_PIT_LOC]     
* MODIFIED DATE  AUTHOR    DESCRIPTION      
*------------------------------------------------------------------      
* {25 OCT 2022}  {LWASINI}   {INITIAL CREATED}      
*******************************************************************/      
CREATE  PROCEDURE [DBO].[UPSERT_CONOPS_PIT_LOC]    
(    
@G_SITE VARCHAR(5)    
)    
AS    
BEGIN    
EXEC     
(    
' DELETE FROM ' +@G_SITE+ '.PIT_LOC'     
    
+' INSERT INTO ' +@G_SITE+ '.PIT_LOC'     
+' SELECT '   
+'  DBPREVIOUS'     
+' ,DBNEXT'     
+' ,DBVERSION'     
+' ,ID'     
+' ,DBNAME'     
+' ,DBKEY'     
+' ,FIELDID'     
+' ,FIELDPIT'     
+' ,FIELDREGION'     
+' ,FIELDBLENDREC'     
+' ,FIELDPATH'     
+' ,FIELDBEAN'     
+' ,FIELDINVBEAN'     
+' ,FIELDHAUL'     
+' ,FIELDORE'     
+' ,FIELDDUMPFEED'     
+' ,FIELDDUMPCAPY'     
+' ,FIELDBINSIZE'     
+' ,FIELDXLOC'     
+' ,FIELDYLOC'     
+' ,FIELDPATHIX'     
+' ,FIELDTIMEDUMP'     
+' ,FIELDZLOC'     
+' ,FIELDSIGNID'     
+' ,FIELDUNIT'     
+' ,FIELDLOAD'     
+' ,FIELDISTIEDOWN'     
+' ,FIELDSTATUS'     
+' ,FIELDLINESTAT'     
+' ,FIELDSPILLAGE'     
+' ,FIELDSIGNPOST'     
+' ,FIELDSHOPTYPE'     
+' ,FIELDDUMPQUEUE'     
+' ,FIELDPCTCAPY'     
+' ,FIELDBAYS'     
+' ,FIELDNOPENALTY'     
+' ,FIELDTIMELAST'     
+' ,FIELDRADIUS'     
+' ,FIELDGPSTYPE'     
+' ,FIELDREASON'     
+' ,FIELDIVTREC'     
+' ,FIELDTDSET'     
+' ,FIELDPRIOR'     
+' ,FIELDAVAILBAYS'     
+' ,FIELDPARKQUEUE'     
+' ,FIELDLASTSTATTIME'     
+' ,FIELDBCNTIME'     
+' ,FIELDTAGDATE'     
+' ,FIELDTAGEQMT'     
+' ,FIELDTRUCKSENROUTE'     
+' ,FIELDLASTASSIGN'     
+' ,FIELDLASTARRIVE'     
+' ,FIELDSPEEDTRAP'     
+' ,FIELDLVSPROXCNT'     
+' ,FIELDIGNUNEXARR'     
+' ,FIELDMETADATA'     
+' ,FIELDDISABLEARRCHK'     
+' ,FIELDINTF_DATA1'     
+' ,FIELDINTF_DATA2'     
+' ,FIELDINTF_DATA3'     
+' ,UTC_CREATED_DATE '     
+' ,UTC_LOGICAL_DELETED_DATE'     
+' FROM ' +@G_SITE+ '.PIT_LOC_STG'    
    
);   
    
END    

