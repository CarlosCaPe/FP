
/******************************************************************      
* PROCEDURE : DBO.[UPSERT_CONOPS_EFH_SNAPSHOT_SEQ]    
* PURPOSE : UPSERT [UPSERT_CONOPS_EFH_SNAPSHOT_SEQ]    
* NOTES     :     
* CREATED : MFAHMI    
* SAMPLE    : EXEC DBO.[UPSERT_CONOPS_EFH_SNAPSHOT_SEQ]     
* MODIFIED DATE  AUTHOR    DESCRIPTION      
*------------------------------------------------------------------      
* {05 JAN 2023}  {MFAHMI}   {INITIAL CREATED}      
*******************************************************************/      
CREATE  PROCEDURE [dbo].[UPSERT_CONOPS_EFH_SNAPSHOT_SEQ]    
   
AS    
BEGIN    
EXEC     
(    
'MERGE DBO.EFH_SNAPSHOT_SEQ AS T '    
+' USING (SELECT '    
+'  siteflag'    
+'  ,shiftid'      
+'  ,ShiftStartDateTime'    
+'  ,ShiftEndDateTime'    
+'  ,currenttime'    
+'  ,EFH'    
+'  ,EFHTarget'    
+'  ,EFHSeq'    
+'  ,UTC_CREATED_DATE'    
+'  FROM DBO.EFH_SNAPSHOT_SEQ_STG) AS S '    
+'  ON  (T.siteflag = S.siteflag ) '    
+'  AND (T.shiftid = S.shiftid ) '    
+'  AND (T.currenttime = S.currenttime ) '    
+'  AND (T.EFHSeq = S.EFHSeq ) '     
+'  WHEN MATCHED '    
+'  THEN UPDATE SET T.ShiftStartDateTime = S.ShiftStartDateTime '    
+'  ,T.ShiftEndDateTime = S.ShiftEndDateTime '    
+'  ,T.EFH = S.EFH '    
+'  ,T.EFHTarget = S.EFHTarget  '    
+'  ,T.UTC_CREATED_DATE = S.UTC_CREATED_DATE '     
+'  WHEN NOT MATCHED '    
+'  THEN INSERT ( '    
+'  siteflag'    
+'  ,shiftid'    
+'  ,ShiftStartDateTime'    
+'  ,ShiftEndDateTime'    
+'  ,currenttime'    
+'  ,EFH'     
+'  ,EFHTarget'    
+'  ,EFHSeq'    
+'  ,UTC_CREATED_DATE'    
+'   ) VALUES( '    
+'  S.siteflag'    
+'  ,S.shiftid'     
+'  ,S.ShiftStartDateTime'    
+'  ,S.ShiftEndDateTime'    
+'  ,S.currenttime'    
+'  ,S.EFH'     
+'  ,S.EFHTarget'    
+'  ,S.EFHSeq'    
+'  ,S.UTC_CREATED_DATE'      
+'  ); '    
    
 );    
END    
    
