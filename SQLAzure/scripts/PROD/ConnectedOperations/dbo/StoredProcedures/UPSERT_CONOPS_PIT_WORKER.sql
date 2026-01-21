

   
    
/******************************************************************      
* PROCEDURE : DBO.[UPSERT_CONOPS_PIT_WORKER]    
* PURPOSE : UPSERT [UPSERT_CONOPS_PIT_WORKER]    
* NOTES     :     
* CREATED : LWASINI    
* SAMPLE    : EXEC DBO.[UPSERT_CONOPS_PIT_WORKER]     
* MODIFIED DATE  AUTHOR    DESCRIPTION      
*------------------------------------------------------------------      
* {25 OCT 2022}  {LWASINI}   {INITIAL CREATED}      
*******************************************************************/      
CREATE  PROCEDURE [DBO].[UPSERT_CONOPS_PIT_WORKER]    
(    
@G_SITE VARCHAR(5)    
)    
AS    
BEGIN    
EXEC     
(    
' DELETE FROM ' +@G_SITE+ '.PIT_WORKER'     
    
+' INSERT INTO ' +@G_SITE+ '.PIT_WORKER'     
+' SELECT '      
+'  DBPREVIOUS'     
+' ,DBNEXT'     
+' ,DBVERSION'     
+' ,ID'     
+' ,DBNAME'     
+' ,DBKEY'     
+' ,FIELDID'     
+' ,FIELDNUMER'     
+' ,FIELDSHIFTS'     
+' ,FIELDSTATUS'     
+' ,FIELDLINEUPCREW'     
+' ,FIELDCREW'     
+' ,FIELDDEPT'     
+' ,FIELDNAME'     
+' ,FIELDSENIORITY'     
+' ,FIELDREGIONLOCK'     
+' ,FIELDLOC'     
+' ,FIELDLOCTIME'     
+' ,FIELDROSTER'     
+' ,FIELDROSTERHIST'     
+' ,FIELDLOGINCREW'     
+' ,FIELDFATGMODE'     
+' ,FIELDFATGWARNTYPE'     
+' ,FIELDFATGWARNPASSED'     
+' ,FIELDNEXTFATGWARNDUE'     
+' ,FIELDFATGWARNSENT'     
+' ,FIELDFATGRESPEXPTD'     
+' ,FIELDFATGDDBLINK'     
+' ,FIELDAREA'     
+' ,FIELDLCOMMENT'     
+' ,UTC_CREATED_DATE '     
+' ,UTC_LOGICAL_DELETED_DATE'     
+' FROM ' +@G_SITE+ '.PIT_WORKER_STG'   
 );    
END    

