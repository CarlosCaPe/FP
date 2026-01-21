CREATE VIEW [cer].[ZZZ_SHIFT_EQMT_TEMP] AS


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


from [cer].[lh2_shift_eqmt_b_temp] --CERREferenceCache.[dbo].[lh2_shift_eqmt_b]

