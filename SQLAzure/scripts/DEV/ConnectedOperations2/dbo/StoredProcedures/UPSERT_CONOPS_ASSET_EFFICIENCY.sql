
  
  
   
      
/******************************************************************        
* PROCEDURE : DBO.[UPSERT_CONOPS_ASSET_EFFICIENCY]      
* PURPOSE : UPSERT [UPSERT_CONOPS_ASSET_EFFICIENCY]      
* NOTES     :       
* CREATED : MFAHMI      
* SAMPLE    : EXEC DBO.[UPSERT_CONOPS_ASSET_EFFICIENCY]       
* MODIFIED DATE  AUTHOR    DESCRIPTION        
*------------------------------------------------------------------        
* {04 DEC 2022}  {MFAHMI}   {INITIAL CREATED}        
* {18 JAN 2023}  {MFAHMI}   {ADJUST COLUMNS TABLE BASED ON SOURCE VIEW}     
* {01 MAR 2023}  {GGOSAL1}  {ADD COLUMN SITEFLAG}   
*******************************************************************/        
CREATE PROCEDURE [dbo].[UPSERT_CONOPS_ASSET_EFFICIENCY]      
(      
@G_SITE VARCHAR(5)      
)      
AS      
BEGIN
DECLARE @G_SITE_ALIAS VARCHAR(5)

SET @G_SITE_ALIAS = CASE WHEN @G_SITE = 'CLI' THEN 'CMX' ELSE @G_SITE END

EXEC       
(      
'MERGE ' +@G_SITE+ '.ASSET_EFFICIENCY AS T '      
+' USING (SELECT '     
+' ''' +@G_SITE_ALIAS+ ''' AS SITEFLAG,' 
+' SHIFTID,'    
+' EQMT,'    
+' FIELDEQMTTYPE,'    
+' EQMTTYPE,'    
+' UNITTYPE,'    
+' STARTDATETIME,'    
+' ENDDATETIME,'    
+' DURATION,'    
+' STATUSIDX,'    
+' STATUS,'    
+' CATEGORYIDX,'    
+' CATEGORY,'    
+' REASONIDX,'    
+' REASONS,'    
+' COMMENTS,'    
+' UTC_CREATED_DATE'    
+' FROM ' +@G_SITE+ '.ASSET_EFFICIENCY_STG) AS S '      
+' ON (T.SHIFTID = S.SHIFTID AND T.EQMT = S.EQMT AND T.STARTDATETIME = S.STARTDATETIME AND T.SITEFLAG = S.SITEFLAG) '       
+' WHEN MATCHED '       
+' THEN UPDATE SET '       
+' T.FIELDEQMTTYPE = S.FIELDEQMTTYPE,'    
+' T.EQMTTYPE = S.EQMTTYPE,'    
+' T.UNITTYPE = S.UNITTYPE,'    
+' T.ENDDATETIME = S.ENDDATETIME,'    
+' T.DURATION = S.DURATION,'     
+' T.STATUSIDX = S.STATUSIDX,'    
+' T.STATUS = S.STATUS,'    
+' T.CATEGORYIDX = S.CATEGORYIDX,'    
+' T.CATEGORY = S.CATEGORY,'    
+' T.REASONIDX = S.REASONIDX,'    
+' T.REASONS = S.REASONS,'    
+' T.COMMENTS = S.COMMENTS,'    
+' T.UTC_CREATED_DATE = S.UTC_CREATED_DATE'     
+' WHEN NOT MATCHED '       
+' THEN INSERT ( '
+' SITEFLAG,' 
+' SHIFTID,'    
+' EQMT,'    
+' FIELDEQMTTYPE,'    
+' EQMTTYPE,'    
+' UNITTYPE,'    
+' STARTDATETIME,'    
+' ENDDATETIME,'    
+' DURATION,'    
+' STATUSIDX,'    
+' STATUS,'    
+' CATEGORYIDX,'    
+' CATEGORY,'    
+' REASONIDX,'    
+' REASONS,'    
+' COMMENTS,'    
+' UTC_CREATED_DATE'     
+'  ) VALUES( '     
+' S.SITEFLAG,' 
+' S.SHIFTID,'    
+' S.EQMT,'    
+' S.FIELDEQMTTYPE,'    
+' S.EQMTTYPE,'    
+' S.UNITTYPE,'    
+' S.STARTDATETIME,'    
+' S.ENDDATETIME,'    
+' S.DURATION,'        
+' S.STATUSIDX,'    
+' S.STATUS,'    
+' S.CATEGORYIDX,'    
+' S.CATEGORY,'    
+' S.REASONIDX,'    
+' S.REASONS,'    
+' S.COMMENTS,'    
+' S.UTC_CREATED_DATE'     
+' ); '      
    
+' DELETE FROM ' +@G_SITE+ '.[ASSET_EFFICIENCY] '    
+' WHERE NOT EXISTS  '    
+' (SELECT 1  '    
+' FROM  ' +@G_SITE+ '.[ASSET_EFFICIENCY_STG]  AS STG   '    
+' WHERE   '    
+' STG.SHIFTID = ' +@G_SITE+ '.[ASSET_EFFICIENCY].SHIFTID AND '
+' STG.EQMT = ' +@G_SITE+ '.[ASSET_EFFICIENCY].EQMT AND '
+' STG.STARTDATETIME = ' +@G_SITE+ '.[ASSET_EFFICIENCY].STARTDATETIME) '    
    
);      
END      
  
