CREATE VIEW [cer].[SHIFT_LOAD_DETAIL_V] AS

--SELECT * FROM CER.SHIFT_LOAD_DETAIL_V
CREATE VIEW [CER].[SHIFT_LOAD_DETAIL_V]
AS

SELECT
	sl.SiteFlag,
	si.ShiftId,
	NULL AS ShiftIndex,
	eqe.FieldId AS Excav,
	exeqt.Description AS Excav_Type,
	NULL AS Excav_OperatorId,
	NULL AS Excav_OperatorName,
	eqt.FieldId AS Truck,
	teqt.Description AS Truck_Type,
	NULL AS Truck_OperatorId,
	NULL AS Truck_OperatorName,
	sl.FieldTons,
	sl.FieldLsizetons,
	NULL AS Grade,
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
FROM CER.shift_load sl WITH(NOLOCK)
LEFT JOIN CER.SHIFT_INFO si WITH(NOLOCK)
	ON sl.ShiftId = si.ShiftId
LEFT JOIN CER.shift_eqmt eqe WITH(NOLOCK)
	ON sl.FieldExcav = eqe.shift_eqmt_id
LEFT JOIN CER.shift_eqmt eqt WITH(NOLOCK)
	ON sl.FieldTruck = eqt.shift_eqmt_id
--LEFT JOIN CER.SHIFT_OPER oe WITH(NOLOCK)
--	ON sl.FieldEoper = oe.Id
--LEFT JOIN CER.SHIFT_OPER ot WITH(NOLOCK)
--	ON sl.FieldToper = ot.Id
LEFT JOIN CER.enum exeqt WITH(NOLOCK)
	ON eqe.FieldEqmttype = exeqt.enum_Id
LEFT JOIN CER.enum teqt
	ON eqt.FieldEqmttype = teqt.enum_Id
--LEFT JOIN CER.shift_grade sg WITH(NOLOCK)
--	ON sl.FieldGrade = sg.Id
LEFT JOIN CER.SHIFT_LOC slo WITH(NOLOCK)
	ON sl.FieldLoc = slo.shift_loc_id
LEFT JOIN dbo.PAYLOAD_FILTER_NEW AS pf WITH (NOLOCK)
	ON pf.SITE_CODE = sl.SiteFlag
	AND pf.EQMT_TYPE = teqt.Description



