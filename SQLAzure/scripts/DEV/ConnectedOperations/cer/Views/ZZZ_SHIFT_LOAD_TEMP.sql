CREATE VIEW [cer].[ZZZ_SHIFT_LOAD_TEMP] AS


CREATE VIEW [cer].[SHIFT_LOAD]  
AS  

Select 
site_code AS siteflag
,DbPrevious
,DbNext
,DbVersion
,ShiftId
,shift_load_id
,shift_dbname
,DbKey
,FieldId
,FieldTruck
,FieldExcav
,FieldGrade
,FieldLoc
,FieldDumprec
,FieldTons
,FieldTimearrive
,FieldTimeload
,FieldTimefull
,FieldCalctravtime
,FieldLoad
,FieldExtraload
,FieldLoadtype
,FieldDist
,FieldEfh
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
,FieldFirstdipper
,FieldLastdipper
,FieldBktcnt
,FieldPandhbucketloads
,FieldAudit
,FieldWeightst
,FieldWeightmeas
,FieldMeasuretime
,FieldGpsxtkl
,FieldGpsytkl
,FieldGpsxex
,FieldGpsyex
,FieldGpsstatex
,FieldGpsstattk
,FieldGpsheadtk
,FieldGpsveltk
,FieldPvs3id
,FieldBktsum
,FieldDumpasn
,FieldLsizetons
,FieldLsizeid
,FieldLsizeversion
,FieldLsizedb
,FieldFuelremain
,FieldFactapply
,FieldDlock
,FieldElock
,FieldEdlock
,FieldRlock
,FieldReconstat
,FieldTimearrivemobile
,FieldTimeloadmobile
,FieldTimefullmobile
,logical_delete_flag
,orig_src_id
,site_code
,Shiftdate
,capture_ts_utc
,integrate_ts_utc
from [cer].[lh2_shift_load_b_temp] --CERREferenceCache.[dbo].[lh2_shift_load_b]

