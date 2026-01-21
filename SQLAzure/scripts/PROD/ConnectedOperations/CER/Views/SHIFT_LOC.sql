CREATE VIEW [CER].[SHIFT_LOC] AS



--SELECT * FROM CER.SHIFT_LOC
CREATE VIEW CER.SHIFT_LOC
AS

SELECT
'CER' AS SiteFlag
,DbPrevious
,DbNext
,DbVersion
,ShiftId
,Id AS shift_loc_id
,DbName AS shift_dbname
,DbKey
,FieldId
,FieldPit
,FieldRegion
,FieldElev
,FieldUnit
,FieldStatus
,FieldReason
,FieldReasonrec
,FieldX
,FieldY
,FieldAudit
,FieldMetadata
,'N' AS logical_delete_flag
,140 AS orig_src_id
,'CER' AS site_code
,GETUTCDATE() AS capture_ts_utc
,GETUTCDATE() AS integrate_ts_utc
,CONVERT(datetime, LEFT(CAST(shiftid AS VARCHAR), 6), 12) AS ShiftDate
FROM CVEOperational.dbo.SHIFTShiftloc WITH(NOLOCK)
WHERE ShiftId >= (SELECT MIN(SHIFTID) FROM CER.SHIFT_INFO)



