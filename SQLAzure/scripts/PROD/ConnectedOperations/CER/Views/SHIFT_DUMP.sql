CREATE VIEW [CER].[SHIFT_DUMP] AS




--SELECT * FROM CER.SHIFT_DUMP
CREATE VIEW CER.SHIFT_DUMP
AS

SELECT
'CER' AS SiteFlag
,DbPrevious
,DbNext
,DbVersion
,ShiftId
,Id AS shift_dump_id
,DbName AS shift_dbname
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
,FieldLsizetons
,FieldLsizedb
,FieldLsizeid
,FieldLsizeversion
,FieldLocactlc
,FieldLocacttp
,FieldLocactrl
,FieldAudit
,FieldGpsxtkd
,FieldGpsytkd
,FieldGpsstat
,FieldGpshead
,FieldGpsvel
,FieldFactapply
,FieldDlock
,FieldElock
,FieldEdlock
,FieldRlock
,FieldReconstat
,FieldTimearrivemobile
,FieldTimedumpmobile
,FieldTimeemptymobile
,FieldWeightst
,FieldMeasuretime
,'N' AS logical_delete_flag
,140 AS orig_src_id
,'CER' AS site_code
,GETUTCDATE() AS capture_ts_utc
,GETUTCDATE() AS integrate_ts_utc
,CONVERT(datetime, LEFT(CAST(shiftid AS VARCHAR), 6), 12) AS ShiftDate
FROM CVEOperational.dbo.SHIFTShiftdump WITH(NOLOCK)
WHERE ShiftId >= (SELECT MIN(SHIFTID) FROM CER.SHIFT_INFO)




