CREATE VIEW [bag].[ZZZ_SHIFT_LOC_TEMP] AS
  
  
CREATE VIEW [BAG].[SHIFT_LOC_TEMP]    
AS    
  
Select   
'BAG' AS siteflag  
,DbPrevious  
,DbNext  
,DbVersion  
,ShiftId  
,ID AS shift_loc_id  
,DBNAME AS shift_dbname  
,DbKey  
,FieldId  
,FieldPit  
,FieldRegion  
,FieldElev  
,FieldUnit  
,FieldStatus  
,FieldReason  
,FieldReasonrec  
,FieldAudit  
,FieldMetadata  
,capture_ts_utc  
,integrate_ts_utc  
,logical_delete_flag  
--,orig_src_id  
--,site_code  
--,Shiftdate  
  
from BAGREferenceCache.[dbo].[lh2_shift_loc_b]  
WHERE SHIFTID >= CONCAT(CONVERT(VARCHAR(8), DATEADD(DAY, - 2,GETDATE()), 12), '001')  