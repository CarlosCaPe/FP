CREATE VIEW [cer].[SHIFT_DUMP] AS




CREATE VIEW [cer].[SHIFT_DUMP]  
AS  

Select 
site_code AS siteflag
,DbPrevious
,DbNext
,DbVersion
,ShiftId
,shift_dump_id
,shift_dbname
,DbKey
,FieldId
,FieldTruck
,FieldLoc
,FieldGrade
,FieldLoadrec
,FieldExcav
,FieldBlast
,FieldBay
,FieldTons
,FieldTimearrive
,FieldTimedump
,FieldTimeempty
,FieldTimedigest
,FieldCalctravtime
,FieldLoad
,FieldExtraload
,FieldDist
,FieldEfh
,FieldLoadtype
,FieldToper
,FieldEoper
,FieldOrigasn
,FieldReasnby
,FieldPathtravtime
,FieldExptraveltime
,FieldExptraveldist
,FieldGpstraveldist
,FieldLocactlc
,FieldLocacttp
,FieldLocactrl
,FieldAudit
,FieldGpsxtkd
,FieldGpsytkd
,FieldGpsstat
,FieldGpshead
,FieldGpsvel
,FieldLsizetons
,FieldLsizeid
,FieldLsizeversion
,FieldLsizedb
,FieldFactapply
,FieldDlock
,FieldElock
,FieldEdlock
,FieldRlock
,FieldReconstat
,FieldTimearrivemobile
,FieldTimedumpmobile
,FieldTimeemptymobile
,capture_ts_utc
,integrate_ts_utc
,logical_delete_flag
,orig_src_id
,site_code
,Shiftdate
from CERREferenceCache.[dbo].[lh2_shift_dump_b] WITH(NOLOCK)
WHERE SHIFTID >= CONCAT(CONVERT(VARCHAR(8), DATEADD(DAY, - 2,GETDATE()), 12), '001')


