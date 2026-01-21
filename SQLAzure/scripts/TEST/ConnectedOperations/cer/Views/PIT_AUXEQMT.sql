CREATE VIEW [cer].[PIT_AUXEQMT] AS



  
CREATE VIEW [cer].[PIT_AUXEQMT]      
AS      
    
Select
site_code AS siteflag
,DbPrevious
,DbNext
,DbVersion
,pit_aux_id AS Id
,pit_dbname AS DbName
,DbKey
,FieldId
,FieldLoc
,FieldExcav
,FieldAux
,FieldVan
,FieldReglock
,FieldBaysplit
,FieldSendcount
,FieldRcvcount
,FieldTimelate
,FieldClock
,FieldTimeassign
,FieldTimelast
,FieldTimenext
,FieldPanelid
,FieldLinereason
,FieldReason
,FieldUnit
,FieldUnitloc
,FieldStatus
,FieldLogin
,FieldPort
,FieldLinestat
,FieldEqmttype
,FieldComment
,FieldLinecmt
,FieldActsim
,FieldActlast
,FieldVsmstbl
,FieldXloc
,FieldYloc
,FieldRadius
,FieldVelocity
,FieldHeading
,FieldDirection
,FieldTiedownaccepted
,FieldZ
,FieldLaststatustime
,FieldLaststatreason
,FieldTiedownproposed
,FieldLastbreak
,FieldCuroper
,FieldCurscope
,FieldCurbreak
,FieldFsgroup
,FieldHpgps
,FieldPv3sup
,FieldLastrftagtime
,FieldPrestartdone
,FieldPresunit
,FieldLvsproxcnt
,FieldLastgpsupdate
,FieldGpsok
,FieldFueltank
,FieldFuelremain
,FieldLastfuelcalc
,FieldFueltime
,FieldFuelfact
,FieldOemfueltime
,FieldHdwtype
,FieldVansize
,FieldVanoccupied
,FieldMaintdate
,FieldLastservicedate
,FieldMainthours
,FieldEnghr
,FieldEnghrtime
,FieldEqreq
,FieldTanksize
,FieldTankremain
,FieldSpray
,FieldGrade
,FieldAuxsched
,FieldAuxtask
,FieldLocnext
,FieldLoclast
,FieldExpected
,FieldActnext
,FieldPmid
,FieldTdbar
,FieldTdrelease
,FieldDevver
,FieldDevhw
,FieldDevbc
,FieldDevop
,FieldRuntime
,FieldFuelenghr
,FieldIntf_data
,NULL AS FieldRulelasttime
,capture_ts_utc
,integrate_ts_utc
,logical_delete_flag
,orig_src_id
,site_code
from [CERReferenceCache].[dbo].[lh2_pit_aux_b] WITH(NOLOCK)
  


