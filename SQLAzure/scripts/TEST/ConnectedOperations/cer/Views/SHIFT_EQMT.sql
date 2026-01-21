CREATE VIEW [cer].[SHIFT_EQMT] AS




CREATE VIEW [cer].[SHIFT_EQMT]  
AS  

Select 
site_code AS siteflag
,DbPrevious
,DbNext
,DbVersion
,ShiftId
,shift_eqmt_id
,shift_dbname
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
,orig_src_id
,site_code
,Shiftdate
from CERREferenceCache.[dbo].[lh2_shift_eqmt_b] WITH(NOLOCK)
WHERE SHIFTID >= CONCAT(CONVERT(VARCHAR(8), DATEADD(DAY, - 2,GETDATE()), 12), '001')


