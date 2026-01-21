CREATE VIEW [cer].[ZZZ_SHIFT_LOC_TEMP] AS


CREATE VIEW [cer].[SHIFT_LOC]  
AS  

Select 
site_code AS siteflag
,DbPrevious
,DbNext
,DbVersion
,ShiftId
,shift_loc_id
,shift_dbname
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
,orig_src_id
,site_code
,Shiftdate

from [cer].[lh2_shift_loc_b_temp] --CERREferenceCache.[dbo].[lh2_shift_loc_b]

