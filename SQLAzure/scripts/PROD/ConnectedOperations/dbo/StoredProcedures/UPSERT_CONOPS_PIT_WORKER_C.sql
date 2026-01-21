




    
    
         
          
/******************************************************************            
* PROCEDURE : DBO.[UPSERT_CONOPS_PIT_WORKER_C]          
* PURPOSE : UPSERT [UPSERT_CONOPS_PIT_WORKER_C]          
* NOTES     :           
* CREATED : MFAHMI          
* SAMPLE    : EXEC DBO.[UPSERT_CONOPS_PIT_WORKER_C]           
* MODIFIED DATE  AUTHOR    DESCRIPTION            
*------------------------------------------------------------------            
* {04 DEC 2022}  {MFAHMI}   {INITIAL CREATED}            
* {01 MAR 2023}  {GGOSAL1}  {ADD COLUMN SITEFLAG}  
* [05 APR 2023}  {GGOSAL1}  {EXPAND DATA UP TO 60 SHIFT}
* {23 DEC 2023}  {GGOSAL1}  {ADD NEW SITE: ABR & TYR}
*******************************************************************/            
CREATE  PROCEDURE [dbo].[UPSERT_CONOPS_PIT_WORKER_C]          
(          
@G_SITE  VARCHAR(5)          
        
)          
AS          
BEGIN          

DECLARE @G_SITE_ALIAS VARCHAR(5)

SET @G_SITE_ALIAS = CASE WHEN @G_SITE = 'CLI' THEN 'CMX' ELSE @G_SITE END  
                   
IF @G_SITE = 'MOR'        
        
EXEC (        
'DELETE FROM ' +@G_SITE+ '.PIT_WORKER_C'        
+' WHERE SHIFTINDEX = (SELECT SHIFTINDEX '        
+'  FROM [DBO].[SHIFT_INFO_V]  '        
+'  WHERE SITEFLAG = ''MOR'' AND SHIFTFLAG =''CURR'')'        
          
+' INSERT INTO ' +@G_SITE+ '.PIT_WORKER_C'         
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
+' FIELDNUMER,'        
+' FIELDSHIFTS,'        
+' FIELDSTATUS,'        
+' FIELDLINEUPCREW,'        
+' FIELDCREW,'        
+' FIELDDEPT,'        
+' FIELDNAME,'        
+' FIELDSENIORITY,'        
+' FIELDREGIONLOCK,'        
+' FIELDLOC,'        
+' FIELDLOCTIME,'        
+' FIELDROSTER,'        
+' FIELDROSTERHIST,'        
+' FIELDLOGINCREW,'        
+' FIELDFATGMODE,'        
+' FIELDFATGWARNTYPE,'        
+' FIELDFATGWARNPASSED,'        
+' FIELDNEXTFATGWARNDUE,'        
+' FIELDFATGWARNSENT,'        
+' FIELDFATGRESPEXPTD,'        
+' FIELDFATGDDBLINK,'        
+' FIELDAREA,'        
+' FIELDLCOMMENT,'        
+' UTC_CREATED_DATE,'        
+' UTC_LOGICAL_DELETED_DATE'        
+' FROM ' +@G_SITE+ '.PIT_WORKER A'        
+' LEFT OUTER JOIN [DBO].[SHIFT_INFO_V] B '        
+' ON B.SITEFLAG= ''MOR'' AND B.SHIFTFLAG = ''CURR'''        
+' WHERE A.ID IS NOT NULL '        
        
        
+'DELETE FROM ' +@G_SITE+ '.PIT_WORKER_C'        
+' WHERE SHIFTINDEX < (SELECT SHIFTINDEX - 60 '        
+'  FROM [DBO].[SHIFT_INFO_V]  '        
+'  WHERE SITEFLAG = ''MOR'' AND SHIFTFLAG =''CURR'')'        
        
);        
        
        
IF @G_SITE = 'BAG'        
        
EXEC (        
'DELETE FROM ' +@G_SITE+ '.PIT_WORKER_C'        
+' WHERE SHIFTINDEX = (SELECT SHIFTINDEX '        
+'  FROM [DBO].[SHIFT_INFO_V]  '        
+'  WHERE SITEFLAG = ''BAG'' AND SHIFTFLAG =''CURR'')'        
          
+' INSERT INTO ' +@G_SITE+ '.PIT_WORKER_C'         
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
+' FIELDNUMER,'        
+' FIELDSHIFTS,'        
+' FIELDSTATUS,'        
+' FIELDLINEUPCREW,'        
+' FIELDCREW,'        
+' FIELDDEPT,'        
+' FIELDNAME,'        
+' FIELDSENIORITY,'        
+' FIELDREGIONLOCK,'        
+' FIELDLOC,'        
+' FIELDLOCTIME,'        
+' FIELDROSTER,'        
+' FIELDROSTERHIST,'        
+' FIELDLOGINCREW,'        
+' FIELDFATGMODE,'        
+' FIELDFATGWARNTYPE,'        
+' FIELDFATGWARNPASSED,'        
+' FIELDNEXTFATGWARNDUE,'        
+' FIELDFATGWARNSENT,'   