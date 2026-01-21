CREATE VIEW [CER].[SHIFT_LOAD] AS



--SELECT * FROM CER.SHIFT_LOAD
CREATE VIEW CER.SHIFT_LOAD
AS

SELECT
'CER' AS SiteFlag
,DbPrevious
,DbNext
,DbVersion
,ShiftId
,Id AS shift_load_id
,DbName AS shift_dbname
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
,FieldLsizetons
,FieldLsizedb
,FieldLsizeid
,FieldLsizeversion
,FieldLocactlc
,FieldLocacttp
,FieldLocactrl
,FieldFirstdipper
,FieldLastdipper
,FieldBktcnt
,FieldShvfirstbkt
,FieldShvlastbkt
,FieldShvbktcnt
,FieldPandhbucketloads
,FieldAudit
,FieldWeightst
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
,'N' AS logical_delete_flag
,140 AS orig_src_id
,'CER' AS site_code
,GETUTCDATE() AS capture_ts_utc
,GETUTCDATE() AS integrate_ts_utc
,CONVERT(datetime, LEFT(CAST(shiftid AS VARCHAR), 6), 12) AS ShiftDate
FROM CVEOperational.dbo.SHIFTShiftload WITH(NOLOCK)
WHERE ShiftId >= (SELECT MIN(SHIFTID) FROM CER.SHIFT_INFO)



