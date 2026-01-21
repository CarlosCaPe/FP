CREATE VIEW [bag].[ZZZ_SHIFT_EQMT_TEMP] AS
  
  
CREATE VIEW [BAG].[SHIFT_EQMT_TEMP]    
AS    
  
Select   
'BAG' AS siteflag  
,DbPrevious  
,DbNext  
,DbVersion  
,ShiftId  
,ID AS shift_eqmt_id  
,DBNAME AS shift_dbname  
,DbKey  
,FieldId  
,FieldPit  
,FieldRegionlock  
,FieldSize  
,FieldTmph  
,FieldReason  
,FieldUnit  
,FieldStatus  
,FieldExtraload  
,FieldNoassign  
,FieldLoadstart  
,FieldEqmttype  
,FieldComment  
,FieldReasonrec  
,FieldOper  
,FieldAudit  
,FieldSubcode  
,FieldSubcode2  
,FieldSituation  
,FieldUser  
,FieldMaintstart  
,FieldMaintpropose  
,FieldWarranty  
,FieldEnghr  
,FieldEnghr2  
,FieldEnghrtime  
,FieldEnghrtime2  
,FieldIsauxil  
,FieldPmid  
,capture_ts_utc  
,integrate_ts_utc  
,logical_delete_flag  
--,orig_src_id  
--,site_code  
--,Shiftdate  
  
  
from BAGREferenceCache.[dbo].[lh2_shift_eqmt_b]  
WHERE SHIFTID >= CONCAT(CONVERT(VARCHAR(8), DATEADD(DAY, - 2,GETDATE()), 12), '001')  