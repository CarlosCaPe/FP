CREATE VIEW [SAF].[SHIFT_LOAD_DETAIL_V] AS

--SELECT * FROM SAF.SHIFT_LOAD_DETAIL_V
CREATE VIEW [SAF].[SHIFT_LOAD_DETAIL_V]
AS

SELECT
	sl.SiteFlag,
	si.ShiftId,
	si.ShiftIndex,
	eqe.FieldId AS Excav,
	exeqt.Description AS Excav_Type,
	oe.FieldId AS Excav_OperatorId,
	oe.FieldName AS Excav_OperatorName,
	eqt.FieldId AS Truck,
	teqt.Description AS Truck_Type,
	ot.FieldId AS Truck_OperatorId,
	ot.FieldName AS Truck_OperatorName,
	sl.FieldTons,
	sl.FieldLsizetons,
	sg.FieldId AS Grade,
	slo.FieldId AS Loc,
	sl.FieldTimearrive,
	DATEADD(SECOND, sl.FieldTimearrive, si.ShiftStartDateTime) AS TimeArrive_TS,
	sl.FieldTimefull,
	DATEADD(SECOND, sl.FieldTimefull, si.ShiftStartDateTime) AS TimeFull_TS,
	FLOOR(DATEDIFF(SECOND, si.ShiftStartDateTime, DATEADD(SECOND, sl.FieldTimefull, si.ShiftStartDateTime)) / 3600.0) AS TimeFull_HOS,
	sl.FieldTimeload,
	DATEADD(SECOND, sl.FieldTimeload, si.ShiftStartDateTime) AS TimeLoad_TS,
	CASE WHEN sl.FieldTons >= pf.MIN_PAYLOAD OR pf.MIN_PAYLOAD IS NULL
		THEN 1
		ELSE 0 END AS PayloadFilter,
	pf.TARGET_PAYLOAD AS TargetPayload
FROM saf.shift_load sl WITH(NOLOCK)
LEFT JOIN saf.SHIFT_INFO si WITH(NOLOCK)
	ON sl.ShiftId = si.ShiftId
LEFT JOIN saf.shift_eqmt eqe WITH(NOLOCK)
	ON sl.FieldExcav = eqe.Id
LEFT JOIN saf.shift_eqmt eqt WITH(NOLOCK)
	ON sl.FieldTruck = eqt.Id
LEFT JOIN saf.SHIFT_OPER oe WITH(NOLOCK)
	ON sl.FieldEoper = oe.Id
LEFT JOIN saf.SHIFT_OPER ot WITH(NOLOCK)
	ON sl.FieldToper = ot.Id
LEFT JOIN saf.enum exeqt WITH(NOLOCK)
	ON eqe.FieldEqmttype = exeqt.Id
LEFT JOIN saf.enum teqt
	ON eqt.FieldEqmttype = teqt.Id
LEFT JOIN saf.shift_grade sg WITH(NOLOCK)
	ON sl.FieldGrade = sg.Id
LEFT JOIN saf.SHIFT_LOC slo WITH(NOLOCK)
	ON sl.FieldLoc = slo.Id
LEFT JOIN dbo.PAYLOAD_FILTER_NEW AS pf WITH (NOLOCK)
	ON pf.SITE_CODE = sl.SiteFlag
	AND pf.EQMT_TYPE = teqt.Description


