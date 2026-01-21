CREATE VIEW [CER].[PIT_LOC] AS



--SELECT * FROM CER.PIT_LOC
CREATE VIEW CER.PIT_LOC
AS

SELECT
'CER' AS siteflag
,DbPrevious
,DbNext
,DbVersion
,ID
,DBNAME
,DbKey
,FieldId
,FieldPit
,FieldRegion
,FieldBlendrec
,FieldPath
,FieldBean
,FieldInvbean
,FieldHaul
,FieldOre
,FieldDumpfeed
,FieldDumpcapy
,FieldBinsize
,FieldXloc
,FieldYloc
,FieldPathix
,FieldTimedump
,FieldZloc
,FieldSignid
,FieldUnit
,FieldLoad
,FieldIstiedown
,FieldStatus
,FieldLinestat
,FieldSpillage
,FieldSignpost
,FieldShoptype
,FieldDumpqueue
,FieldPctcapy
,FieldBays
,FieldNopenalty
,FieldTimelast
,FieldRadius
,FieldGpstype
,FieldReason
,FieldIvtrec
,FieldTdset
,FieldPrior
,FieldAvailbays
,FieldParkqueue
,FieldLaststattime
,FieldBcntime
,FieldTagdate
,FieldTageqmt
,FieldTrucksenroute
,FieldLastassign
,FieldLastarrive
,FieldSpeedtrap
,FieldLvsproxcnt
,FieldIgnunexarr
,FieldMetadata
,FieldDisablearrchk
,FieldIntf_data1
,FieldIntf_data2
,FieldIntf_data3
,'N' AS logical_delete_flag
,140 AS orig_src_id
,'CER' AS site_code
,GETUTCDATE() AS capture_ts_utc
,GETUTCDATE() AS integrate_ts_utc
FROM CVEOperational.dbo.PITPitLoc WITH(NOLOCK)



