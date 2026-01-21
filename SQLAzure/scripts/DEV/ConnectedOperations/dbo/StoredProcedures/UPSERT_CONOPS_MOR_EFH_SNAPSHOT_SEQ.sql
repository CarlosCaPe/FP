


/******************************************************************    
* PROCEDURE : DBO.[UPSERT_CONOPS_MOR_EFH_SNAPSHOT_SEQ]  
* PURPOSE : UPSERT [UPSERT_CONOPS_MOR_EFH_SNAPSHOT_SEQ]  
* NOTES     :   
* CREATED : LWASINI  
* SAMPLE    : EXEC DBO.[UPSERT_CONOPS_MOR_EFH_SNAPSHOT_SEQ]   
* MODIFIED DATE  AUTHOR    DESCRIPTION    
*------------------------------------------------------------------    
* {25 OCT 2022}  {LWASINI}   {INITIAL CREATED}    
*******************************************************************/    
CREATE  PROCEDURE [dbo].[UPSERT_CONOPS_MOR_EFH_SNAPSHOT_SEQ]  
 
AS  
BEGIN  
EXEC   
(  
'MERGE MOR.EFH_SNAPSHOT_SEQ AS T '  
+' USING (SELECT '  
+'  shiftflag '  
+'  ,siteflag'  
+'  ,shiftid'    
+'  ,ShiftStartDateTime'  
+'  ,ShiftEndDateTime'  
+'  ,currenttime'  
+'  ,EFH'  
+'  ,EFHShiftTarget'  
+'  ,EFHTarget'  
+'  ,EFHSeq'  
+'  ,UTC_CREATED_DATE'  
+'  FROM MOR.EFH_SNAPSHOT_SEQ_STG) AS S '  
+'  ON (T.shiftflag = S.shiftflag ) '  
+'  AND (T.siteflag = S.siteflag ) '  
+'  AND (T.shiftid = S.shiftid ) '  
+'  AND (T.currenttime = S.currenttime ) '  
+'  AND (T.EFHSeq = S.EFHSeq ) '   
+'  WHEN MATCHED '  
+'  THEN UPDATE SET T.ShiftStartDateTime = S.ShiftStartDateTime '  
+'  ,T.ShiftEndDateTime = S.ShiftEndDateTime '  
+'  ,T.EFH = S.EFH '  
+'  ,T.EFHShiftTarget = S.EFHShiftTarget '  
+'  ,T.EFHTarget = S.EFHTarget  '  
+'  ,T.UTC_CREATED_DATE = S.UTC_CREATED_DATE '   
+'  WHEN NOT MATCHED '  
+'  THEN INSERT ( '  
+'  shiftflag '  
+'  ,siteflag'  
+'  ,shiftid'  
+'  ,ShiftStartDateTime'  
+'  ,ShiftEndDateTime'  
+'  ,currenttime'  
+'  ,EFH'  
+'  ,EFHShiftTarget'  
+'  ,EFHTarget'  
+'  ,EFHSeq'  
+'  ,UTC_CREATED_DATE'  
+'   ) VALUES( '  
+'  S.shiftflag '  
+'  ,S.siteflag'  
+'  ,S.shiftid'   
+'  ,S.ShiftStartDateTime'  
+'  ,S.ShiftEndDateTime'  
+'  ,S.currenttime'  
+'  ,S.EFH'  
+'  ,S.EFHShiftTarget'  
+'  ,S.EFHTarget'  
+'  ,S.EFHSeq'  
+'  ,S.UTC_CREATED_DATE'    
+'  ); '  
  
 );  
END  
  
