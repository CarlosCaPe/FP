CREATE VIEW [CER].[SHIFT_EQMT] AS




--SELECT * FROM CER.SHIFT_EQMT
CREATE VIEW CER.SHIFT_EQMT
AS

SELECT
'CER' AS SiteFlag
,DbPrevious
,DbNext
,DbVersion
,ShiftId
,Id AS shift_eqmt_id
,DbName AS shift_dbname
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
,'N' AS logical_delete_flag
,140 AS orig_src_id
,'CER' AS site_code
,GETUTCDATE() AS capture_ts_utc
,GETUTCDATE() AS integrate_ts_utc
,CONVERT(datetime, LEFT(CAST(shiftid AS VARCHAR), 6), 12) AS ShiftDate
FROM CVEOperational.dbo.SHIFTShifteqmt WITH(NOLOCK)
WHERE ShiftId >= (SELECT MIN(SHIFTID) FROM CER.SHIFT_INFO)




