
  
  
   
    
/******************************************************************      
* PROCEDURE : DBO.[UPSERT_CONOPS_SHIFT_EQMT]    
* PURPOSE : UPSERT [UPSERT_CONOPS_SHIFT_EQMT]    
* NOTES     :     
* CREATED : LWASINI    
* SAMPLE    : EXEC DBO.[UPSERT_CONOPS_SHIFT_EQMT]     
* MODIFIED DATE  AUTHOR    DESCRIPTION      
*------------------------------------------------------------------      
* {25 OCT 2022}  {LWASINI}   {INITIAL CREATED}      
* {22 FEB 2023}  {MFAHMI}   {Enhancement the logic to add delete of records}  
* {01 MAR 2023}  {GGOSAL1}  {ADD COLUMN SITEFLAG}
*******************************************************************/      
CREATE PROCEDURE [dbo].[UPSERT_CONOPS_SHIFT_EQMT]    
(    
@G_SITE VARCHAR(5)    
)    
AS    
BEGIN 
DECLARE @G_SITE_ALIAS VARCHAR(5)

SET @G_SITE_ALIAS = CASE WHEN @G_SITE = 'CLI' THEN 'CMX' ELSE @G_SITE END
EXEC     
(    
'MERGE '+@G_SITE+ '.SHIFT_EQMT AS T '    
+' USING (SELECT '   
+' ''' +@G_SITE_ALIAS+ ''' AS SITEFLAG' 
+' ,DBPREVIOUS'    
+' ,DBNEXT'    
+' ,DBVERSION'    
+' ,SHIFTID'    
+' ,ID'    
+' ,DBNAME'    
+' ,DBKEY'    
+' ,FIELDID'    
+' ,FIELDPIT'    
+' ,FIELDREGIONLOCK'    
+' ,FIELDSIZE'    
+' ,FIELDTMPH'    
+' ,FIELDREASON'    
+' ,FIELDUNIT'    
+' ,FIELDSTATUS'    
+' ,FIELDEXTRALOAD'    
+' ,FIELDNOASSIGN'    
+' ,FIELDLOADSTART'    
+' ,FIELDEQMTTYPE'    
+' ,FIELDCOMMENT'    
+' ,FIELDREASONREC'    
+' ,FIELDOPER'    
+' ,FIELDAUDIT'    
+' ,FIELDSUBCODE'    
+' ,FIELDSUBCODE2'    
+' ,FIELDSITUATION'    
+' ,FIELDUSER'    
+' ,FIELDMAINTSTART'    
+' ,FIELDMAINTPROPOSE'    
+' ,FIELDWARRANTY'    
+' ,FIELDENGHR'    
+' ,FIELDENGHR2'    
+' ,FIELDENGHRTIME'    
+' ,FIELDENGHRTIME2'    
+' ,FIELDISAUXIL'    
+' ,FIELDPMID'    
+' ,UTC_CREATED_DATE '    
+' ,UTC_LOGICAL_DELETED_DATE'    
+' FROM ' +@G_SITE+ '.SHIFT_EQMT_STG'    
+' WHERE CHANGE_TYPE IN (''U'',''I'')) AS S '    
+' ON (T.ID = S.ID AND T.SITEFLAG = S.SITEFLAG) '    
+' WHEN MATCHED '    
+' THEN UPDATE SET '    
+' T.DBPREVIOUS = S.DBPREVIOUS'    
+' ,T.DBNEXT = S.DBNEXT'    
+' ,T.DBVERSION = S.DBVERSION'    
+' ,T.SHIFTID = S.SHIFTID'    
+' ,T.DBNAME = S.DBNAME'    
+' ,T.DBKEY = S.DBKEY'    
+' ,T.FIELDID = S.FIELDID'    
+' ,T.FIELDPIT = S.FIELDPIT'    
+' ,T.FIELDREGIONLOCK = S.FIELDREGIONLOCK'    
+' ,T.FIELDSIZE = S.FIELDSIZE'    
+' ,T.FIELDTMPH = S.FIELDTMPH'    
+' ,T.FIELDREASON = S.FIELDREASON'    
+' ,T.FIELDUNIT = S.FIELDUNIT'    
+' ,T.FIELDSTATUS = S.FIELDSTATUS'    
+' ,T.FIELDEXTRALOAD = S.FIELDEXTRALOAD'    
+' ,T.FIELDNOASSIGN = S.FIELDNOASSIGN'    
+' ,T.FIELDLOADSTART = S.FIELDLOADSTART'    
+' ,T.FIELDEQMTTYPE = S.FIELDEQMTTYPE'    
+' ,T.FIELDCOMMENT = S.FIELDCOMMENT'    
+' ,T.FIELDREASONREC = S.FIELDREASONREC'    
+' ,T.FIELDOPER = S.FIELDOPER'    
+' ,T.FIELDAUDIT = S.FIELDAUDIT'    
+' ,T.FIELDSUBCODE = S.FIELDSUBCODE'    
+' ,T.FIELDSUBCODE2 = S.FIELDSUBCODE2'    
+' ,T.FIELDSITUATION = S.FIELDSITUATION'    
+' ,T.FIELDUSER = S.FIELDUSER'    
+' ,T.FIELDMAINTSTART = S.FIELDMAINTSTART'    
+' ,T.FIELDMAINTPROPOSE = S.FIELDMAINTPROPOSE'    
+' ,T.FIELDWARRANTY = S.FIELDWARRANTY'    
+' ,T.FIELDENGHR = S.FIELDENGHR'    
+' ,T.FIELDENGHR2 = S.FIELDENGHR2'    
+' ,T.FIELDENGHRTIME = S.FIELDENGHRTIME'    
+' ,T.FIELDENGHRTIME2 = S.FIELDENGHRTIME2'    
+' ,T.FIELDISAUXIL = S.FIELDISAUXIL'    
+' ,T.FIELDPMID = S.FIELDPMID'    
+' ,T.UTC_CREATED_DATE = S.UTC_CREATED_DATE '    
+' ,T.UTC_LOGICAL_DELETED_DATE = S.UTC_LOGICAL_DELETED_DATE '    
+' WHEN NOT MATCHED '    
+' THEN INSERT ( ' 
+'  SITEFLAG' 
+' ,DBPREVIOUS'    
+' ,DBNEXT'    
+' ,DBVERSION'    
+' ,SHIFTID'    
+' ,ID'    
+' ,DBNAME'    
+' ,DBKEY'    
+' ,FIELDID'    
+' ,FIELDPIT'    
+' ,FIELDREGIONLOCK'    
+' ,FIELDSIZE'    
+' ,FIELDTMPH'    
+' ,FIELDREASON'    
+' ,FIELDUNIT'    
+' ,FIELDSTATUS'    
+' ,FIELDEXTRALOAD'    
+' ,FIELDNOASSIGN'    
+' ,FIELDLO